
#* Mostrar informações segundo ID
#* @param id
#* @get /info
function(id) {
    # Ler variáveis de ambiente
    readRenviron("../.Renviron")

    # Criar conexão com o banco
    con <- duckdb::dbConnect(duckdb::duckdb(), ":memory:")
    invisible(DBI::dbExecute(con, "INSTALL httpfs;"))
    invisible(DBI::dbExecute(con, "LOAD httpfs;"))
    invisible(DBI::dbExecute(con, glue::glue("SET s3_region='{Sys.getenv('S3_REGION')}';")))
    invisible(DBI::dbExecute(con, glue::glue("SET s3_endpoint='{Sys.getenv('S3_ENDPOINT')}';")))
    invisible(DBI::dbExecute(con, glue::glue("SET s3_access_key_id='{Sys.getenv('S3_ACCESS_KEY_ID')}';")))
    invisible(DBI::dbExecute(con, glue::glue("SET s3_secret_access_key='{Sys.getenv('S3_SECRET_ACCESS_KEY')}';")))

    # Consulta
    resposta <- dplyr::tbl(con, "s3://duckdb-ser/nyc-taxi.parquet") |>
        dplyr::filter(id == input) |> dplyr::as_tibble() |> as.data.frame()

    duckdb::dbDisconnect(con, shutdown = TRUE)

    # Resultado
    return(jsonlite::toJSON(resposta))
}
