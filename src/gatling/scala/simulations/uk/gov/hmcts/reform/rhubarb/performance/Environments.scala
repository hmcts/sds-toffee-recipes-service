package uk.gov.hmcts.reform.rhubarb.performance

object Environments {

    val baseUrl : String = scala.util.Properties.envOrElse("TEST_URL","http://localhost:4550")

}
