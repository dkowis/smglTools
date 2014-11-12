import sbt._
import Keys._

object Library {

  val akkaVersion = "2.3.6"
  val log4jVersion = "2.1"

  val scalatest = "org.scalatest" %% "scalatest" % "2.2.1"
  val scopt = "com.github.scopt" %% "scopt" % "3.2.0"
  val scalaLogging = "com.typesafe.scala-logging" %% "scala-logging" % "3.1.0"
  val log4j2_core = "org.apache.logging.log4j" % "log4j-core" % log4jVersion
  val log4j2_api = "org.apache.logging.log4j" % "log4j-api" % log4jVersion
  val log4j2_slf4j = "org.apache.logging.log4j" % "log4j-slf4j-impl" % log4jVersion
  val akka = "com.typesafe.akka" %% "akka-actor" % akkaVersion
  val akka_slf4j = "com.typesafe.akka" %% "akka-slf4j" % akkaVersion
  val sprayJson = "io.spray" %% "spray-json" % "1.3.1"
  val httpClient = "org.apache.httpcomponents" % "httpclient" % "4.3.6" exclude("commons-logging", "commons-logging")
  val jclBridge = "org.slf4j" % "jcl-over-slf4j" % "1.7.7"
}

object Dependencies {

  import Library._

  val deps = Seq(
    scalatest % "test",
    //akka,
    //akka_slf4j,
    sprayJson,
    httpClient,
    jclBridge,
    //scopt,
    log4j2_core,
    log4j2_api,
    log4j2_slf4j,
    scalaLogging
  )
}