package org.shlrm

import java.io._

import com.typesafe.scalalogging.LazyLogging
import org.apache.http.client.methods.HttpGet
import org.apache.http.client.protocol.HttpClientContext
import org.apache.http.impl.client.CloseableHttpClient
import org.shlrm.SpellFormat._

import scala.concurrent.{ExecutionContext, Future}
import scala.io.Source
import scala.sys.process.BasicIO

case class SpellDownloader(spell: Spell, client: CloseableHttpClient, executionContext: ExecutionContext) extends LazyLogging {

  val sourceRoot = "/var/spool/sorcery"

  lazy val stdOut = new StringBuffer
  lazy val stdErr = new StringBuffer

  /**
   * Determines if the file needs to be downloaded
   * //TODO: verify the signature
   * @param file
   * @return
   */
  def isDownloadNecessary(file: File): Boolean = {
    if (!file.exists()) {
      true
    } else {
      val url = file.toURI.toURL
      val stream = url.openStream()

      val size = try {
        stream.available()
      } finally {
        stream.close()
      }
      size == 0
    }
  }

  val summonStatus: Future[SummonResult] = Future {
    //Check to see if the file exists in /var/spool/sorcery
    val sourceFileResults = spell.sourceFiles.map { sourceFile =>
      val destination = new File(sourceRoot, sourceFile.fileName)
      if (isDownloadNecessary(destination)) {
        //It needs to be downloaded
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
              val input = new BufferedInputStream(response.getEntity.getContent)
              val buffer = new Array[Byte](1024)
              try {
                //This is the magic to write streams. such scala. wow.
                Stream.continually(input.read(buffer)).takeWhile(_ != -1).foreach(count => os.write(buffer, 0, count))
              } finally {
                os.close()
                input.close()
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
