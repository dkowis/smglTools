import sbt._
import Keys._

object Library {
  val scalatest = "org.scalatest" %% "scalatest" % "2.2.1"
  val scopt = "com.github.scopt" %% "scopt" % "3.2.0"
  val scalaLogging = "com.typesafe.scala-logging" %% "scala-logging" % "3.1.0"
  val log4j2_core = "org.apache.logging.log4j" % "log4j-core" % "2.1"
  val log4j2_api = "org.apache.logging.log4j" % "log4j-api" % "2.1"
  val log4j2_slf4j = "org.apache.logging.log4j" % "log4j-slf4j-impl" % "2.1"
}

object Dependencies {

  import Library._

  val deps = Seq(
    scalatest % "test",
    //scopt,
    log4j2_core,
    log4j2_api,
    log4j2_slf4j,
    scalaLogging
  )
}