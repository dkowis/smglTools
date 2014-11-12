package org.shlrm

import java.io.{BufferedOutputStream, File, FileOutputStream}

import com.typesafe.scalalogging.LazyLogging
import org.apache.http.client.methods.HttpGet
import org.apache.http.client.protocol.HttpClientContext
import org.apache.http.impl.client.CloseableHttpClient
import org.shlrm.SpellFormat._

import scala.concurrent.{ExecutionContext, Future}
import scala.sys.process.BasicIO

case class SpellDownloader(spell: Spell, client:CloseableHttpClient, executionContext: ExecutionContext) extends LazyLogging {
  lazy val stdOut = new StringBuffer
  lazy val stdErr = new StringBuffer

  val summonStatus:Future[SummonResult] = Future {
    //Check to see if the file exists in /var/spool/sorcery
    val sourceFileResults = spell.sourceFiles.map { sourceFile =>
      val destination = new File("/var/spool/sorcery", sourceFile.fileName)
      if (!destination.exists()) {
        //The file doesn't exist! we should download it
        //TODO: just using first url now, because lameness
        if (sourceFile.urls.nonEmpty) {
          val url = sourceFile.urls.head //TODO: should do something with all the urls
          if (url.startsWith("http")) {
            logger.info(s"Internally downloading $url to ${destination.getAbsolutePath}")
            //I can download this
            val context = HttpClientContext.create()
            val get = new HttpGet(url)

            val response = client.execute(get, context)
            try {
              //Open the file for output
              val os = new BufferedOutputStream(new FileOutputStream(destination))
              try {
                BasicIO.transferFully(response.getEntity.getContent, os) //TODO: this might not be the right way to do things
              } finally {
                os.close()
              }
            } finally {
              response.close()
            }
            logger.info(s"Downloaded $url to ${destination.getAbsolutePath}")
            SourceFileResult(sourceFile, "Downloaded!")
          } else {
            logger.info(s"Unable to download internally: $url")
            //TODO: I cannot download this, fork to summon
            SourceFileResult(sourceFile, "Need to fork to summon", successful = false)
          }
        } else {
          SourceFileResult(sourceFile, "No URLS to download", successful = true)
        }
      } else {
        SourceFileResult(sourceFile, "Already exists", successful = true)
      }
    }
    //Build the final summon result
    SummonResult(spell, sourceFileResults)
  }(executionContext) //Explicitly use our execution context
}
