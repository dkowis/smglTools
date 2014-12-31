package org.shlrm

import java.util.concurrent.Executors

import com.typesafe.scalalogging.LazyLogging
import org.apache.http.impl.client.{CloseableHttpClient, HttpClients}
import org.apache.http.impl.conn.PoolingHttpClientConnectionManager
import org.shlrm.SpellFormat.SummonResult

import scala.concurrent.{Future, Await, ExecutionContext}

object ParallelDownload extends App with LazyLogging {

  import scala.concurrent.duration._

  //Can run 10 downloads at a time
  val internalDownloaderEC = ExecutionContext.fromExecutor(Executors.newFixedThreadPool(10))

  //Another one for other work
  implicit val defaultExecutionContext = ExecutionContext.fromExecutor(Executors.newFixedThreadPool(3))

  logger.info("Starting up!")

  import scala.sys.process._

  val spellInfo = new SpellInfoProvider()
  logger.info("Created Spell info provider! Woo")

  //Set up an HTTP client
  val cm = new PoolingHttpClientConnectionManager()
  val client: CloseableHttpClient = HttpClients.custom().setConnectionManager(cm).build()

  val spellList: List[Future[SummonResult]] = Seq("bash", "-c", ". /etc/sorcery/config; codex_get_all_spells").lineStream.toList.map { l =>
    spellInfo.spellInfo(l).flatMap { spell =>
      logger.debug(s"transforming $l into a SpellDownloader")
      SpellDownloader(spell, client, internalDownloaderEC).summonStatus.map(s => s)
    }
  }

  logger.info("After collected spell info")

  spellList.toIterator.foreach { f =>
    logger.info("Awaiting result")
    val result = Await.result(f, 10 minutes)

    val spellPath = result.spell.spellPath
    logger.info(s"acquired result for $spellPath")
    //Convert the sourcefile results into something I can read
    if (result.sourceFileResults.map(_.successful).forall(_ == true)) {
      logger.info(s"Successful spell: $spellPath: ")
    } else {
      val sfResults = result.sourceFileResults.map{ sf =>
        s"${sf.sourceFile}: ${sf.result}"
      }.mkString("\n")
      logger.info(s"    Failed spell: $spellPath\n$sfResults")
    }
  }

  //Shutdown the http client
  client.close()
  cm.close()

}
