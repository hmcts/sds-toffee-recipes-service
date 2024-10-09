package uk.gov.hmcts.reform.rhubarb.performance

import scala.concurrent.duration._

import io.gatling.core.Predef._
import io.gatling.http.Predef._
import io.gatling.jdbc.Predef._

class RhubarbReferenceSimulation extends Simulation {

	val httpProtocol = http
		.baseUrl(Environments.baseUrl)
		.inferHtmlResources()
		.acceptHeader("image/webp,image/apng,image/*,*/*;q=0.8")
		.acceptEncodingHeader("gzip, deflate")
		.acceptLanguageHeader("en-GB,en-US;q=0.9,en;q=0.8")
		.userAgentHeader("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.181 Safari/537.36")

	val headers_0 = Map(
		"Accept" -> "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8",
		"Upgrade-Insecure-Requests" -> "1")

	val headers_1 = Map("Pragma" -> "no-cache")



	val scn = scenario("RhubarbReferenceSimulation")
		.exec(http("request_0")
			.get("/recipes")
			.headers(headers_0)
			.resources(http("request_1")
			.get("/favicon.ico")
			.headers(headers_1)))
		.pause(1)
		.exec(http("request_2")
			.get("/recipes")
			.headers(headers_0)
			.resources(http("request_3")
			.get("/favicon.ico")
			.headers(headers_1)))
		.pause(1)
		.exec(http("request_4")
			.get("/recipes")
			.headers(headers_0)
			.resources(http("request_5")
			.get("/favicon.ico")
			.headers(headers_1)))
		.pause(1)
		.exec(http("request_6")
			.get("/recipes")
			.headers(headers_0)
			.resources(http("request_7")
			.get("/favicon.ico")
			.headers(headers_1)))
		.pause(1)
		.exec(http("request_8")
			.get("/recipes")
			.headers(headers_0)
			.resources(http("request_9")
			.get("/favicon.ico")
			.headers(headers_1)))
		.pause(1)
		.exec(http("request_10")
			.get("/recipes")
			.headers(headers_0)
			.resources(http("request_11")
			.get("/favicon.ico")
			.headers(headers_1)))
		.pause(1)
		.exec(http("request_12")
			.get("/recipes")
			.headers(headers_0)
			.resources(http("request_13")
			.get("/favicon.ico")
			.headers(headers_1)))
		.pause(1)
		.exec(http("request_14")
			.get("/recipes")
			.headers(headers_0)
			.resources(http("request_15")
			.get("/favicon.ico")
			.headers(headers_1)))
		.pause(1)
		.exec(http("request_16")
			.get("/recipes")
			.headers(headers_0)
			.resources(http("request_17")
			.get("/favicon.ico")
			.headers(headers_1)))
		.pause(1)
		.exec(http("request_18")
			.get("/recipes")
			.headers(headers_0)
			.resources(http("request_19")
			.get("/favicon.ico")
			.headers(headers_1)))

	setUp(scn.inject(atOnceUsers(1))).protocols(httpProtocol)
}
