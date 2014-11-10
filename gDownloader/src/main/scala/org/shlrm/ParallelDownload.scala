package org.shlrm

import com.typesafe.scalalogging.LazyLogging

object ParallelDownload extends App with LazyLogging {

  // get a list of all the spells again

  logger.info("Starting up!")

  import scala.sys.process._

  val lineStream = Seq("bash", "-c", ". /etc/sorcery/config; codex_get_all_spells").lineStream

  //Got a stream of spells, now I need to get a bit of information for each spell
  //Create an actor to do this?
}
