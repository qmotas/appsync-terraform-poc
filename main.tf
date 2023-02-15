terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_appsync_graphql_api" "this" {
  authentication_type = "API_KEY"
  name                = "AppSync Playground(terraform)"
  schema              = file("schema.graphql")
}

resource "aws_appsync_datasource" "catstronauts_rest_api" {
  api_id = aws_appsync_graphql_api.this.id
  name   = "catstronauts_rest_api"
  type   = "HTTP"

  http_config {
    endpoint = "https://odyssey-lift-off-rest-api.herokuapp.com"
  }
}

resource "aws_appsync_function" "get_tracks_for_home" {
  api_id      = aws_appsync_graphql_api.this.id
  data_source = aws_appsync_datasource.catstronauts_rest_api.name
  name        = "getTracksForHome"
  code        = file("functions/getTracksForHome.js")

  runtime {
    name            = "APPSYNC_JS"
    runtime_version = "1.0.0"
  }
}

resource "aws_appsync_function" "get_author" {
  api_id      = aws_appsync_graphql_api.this.id
  data_source = aws_appsync_datasource.catstronauts_rest_api.name
  name        = "getAuthor"
  code        = file("functions/getAuthor.js")

  runtime {
    name            = "APPSYNC_JS"
    runtime_version = "1.0.0"
  }
}

resource "aws_appsync_resolver" "query_tracks_for_home" {
  api_id = aws_appsync_graphql_api.this.id
  type   = "Query"
  field  = "tracksForHome"
  kind   = "PIPELINE"
  code   = file("resolvers/Query.tracksForHome.js")

  runtime {
    name            = "APPSYNC_JS"
    runtime_version = "1.0.0"
  }

  pipeline_config {
    functions = [
      aws_appsync_function.get_tracks_for_home.function_id,
    ]
  }
}

resource "aws_appsync_resolver" "track_author" {
  api_id = aws_appsync_graphql_api.this.id
  type   = "Track"
  field  = "author"
  kind   = "PIPELINE"
  code   = file("resolvers/Track.author.js")

  runtime {
    name            = "APPSYNC_JS"
    runtime_version = "1.0.0"
  }

  pipeline_config {
    functions = [
      aws_appsync_function.get_author.function_id,
    ]
  }
}
