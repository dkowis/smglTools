package org.shlrm

import org.scalatest.{FunSpec, Matchers}

import scala.concurrent.{Await, Future}

class SpellInfoProviderTest extends FunSpec with Matchers {

  import org.shlrm.SpellFormat._

  import scala.concurrent.ExecutionContext.Implicits.global
  import scala.concurrent.duration._


  it("can parse a single requested payload into json!") {
    val provider = new SpellInfoProvider("/testConstant.sh")

    val future = provider.spellInfo("test1")

    val result = Await.result(future, 2 seconds)

    //Comparing the string representations works... this is super weird
    result.toString shouldBe test1Spell.toString

    provider.shutdown()
  }

  it("can parse multiple requested payloads into json!") {
    val provider = new SpellInfoProvider("/testConstant.sh")

    val future1 = provider.spellInfo("test1")
    val future2 = provider.spellInfo("test1")
    val future3 = provider.spellInfo("test1")

    val all: Future[List[Spell]] = Future.sequence(List(future1, future2, future3))

    val result = Await.result(all, 2 seconds)

    result.foreach { r =>
      r.toString shouldBe test1Spell.toString
    }
    provider.shutdown()
  }

  it("can parse multiple different requested payloads") {
    val provider = new SpellInfoProvider("/testConstant.sh")

    val things = Map(
      "test1" -> test1Spell,
      "test2" -> test2Spell,
      "test3" -> test3Spell
    )

    val futures = things.map { case (k, v) =>
      k -> provider.spellInfo(k)
    }

    futures.foreach { case (k, v) =>
      val result = Await.result(v, 1 second)
      result.toString shouldBe things(k).toString
    }

    provider.shutdown()
  }

  val test1Spell = Spell("/var/lib/sorcery/codex/stable/crypto/gnupg",
    "1.4.12",
    List(
      SourceFile(
        "gnupg-1.4.12.tar.bz2",
        "GnuPG.gpg:gnupg-1.4.12.tar.bz2.sig:VERIFIED_UPSTREAM_KEY",
        List(
          "ftp://ftp.gnupg.org/gcrypt/gnupg/gnupg-1.4.12.tar.bz2",
          "ftp://ftp.planetmirror.com/pub/gnupg/gnupg/gnupg-1.4.12.tar.bz2",
          "ftp://sunsite.dk/pub/security/gcrypt/gnupg/gnupg-1.4.12.tar.bz2",
          "ftp://ftp.franken.de/pub/crypt/mirror/ftp.gnupg.org/gcrypt/gnupg/gnupg-1.4.12.tar.bz2",
          "ftp://ftp.linux.it/pub/mirrors/gnupg/gnupg/gnupg-1.4.12.tar.bz2"
        )
      ),
      SourceFile(
        "gnupg-1.4.12.tar.bz2.sig",
        "signature",
        List(
          "ftp://ftp.gnupg.org/gcrypt/gnupg/gnupg-1.4.12.tar.bz2.sig"
        )
      )
    )
  )

  val test2Spell = Spell(
    "/var/lib/sorcery/codex/stable/mail/cone",
    "0.84",
    List(SourceFile("cone-0.84.tar.bz2",
      "courier.gpg:cone-0.84.tar.bz2.sig:UPSTREAM_KEY",
      List("http://internap.dl.sourceforge.net/sourceforge/courier/cone-0.84.tar.bz2")),
      SourceFile("cone-0.84.tar.bz2.sig", "signature", List("http://internap.dl.sourceforge.net/sourceforge/courier/cone-0.84.tar.bz2.sig"))
    ))
  val test3Spell = Spell("/var/lib/sorcery/codex/stable/mail/putmail", "1.4",
    List(SourceFile("putmail.py-1.4.tar.bz2",
      "sha512:7f58ba107e9513f268f01f7d4d8bd6013b72190ef648225bed12631195a9d82b2fb7ff11142ca6df358f55bda1e64b7c2e3e76dcdfa318d07035b5024cc0f8a4",
      List("http://internap.dl.sourceforge.net/sourceforge/putmail/putmail.py-1.4.tar.bz2"))
    ))


}
