## install rhdf5 package from BioConductor if necessary
#source("https://bioconductor.org/biocLite.R")
#biocLite("rhdf5")
#install.packages("dplyr")
#install.packages("RPostgreSQL")
library(rhdf5)
library(dplyr)
library(RPostgreSQL)


## initialize database
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, 
                 dbname = "msd", 
                 host = "localhost", 
                 port = 5432, 
                 user = "postgres", 
                 password = "postgres"
                 )

## set base path of the h5 folder structure & batch size
#base.path <- "C://Users//kgreger//Downloads//MillionSongSubset//data"
base.path <- "~/Desktop/MSD/"
batch.size <- 10000

## get list of all h5 files
list.of.files <- dir(path = base.path, 
                     pattern = "\\.h5")

## loop through the first batch of h5 files
for (h5 in list.of.files[1:batch.size]) {
  print(paste0(h5, "\n"))
  # open h5 file
  h5f = H5Fopen(paste(base.path, 
                      h5, 
                      sep = "/"))
  
  # extract song data (skipping bars, sections, segments, and tatums)
  if (length(h5f$metadata$songs$artist_id) > 0) 
  {
    song <- data.frame(h5f$analysis$songs, 
                       h5f$metadata$songs, 
                       h5f$musicbrainz$songs) %>% 
      select(-starts_with("idx")) %>% 
      select(-starts_with("time_signature")) %>% 
      select(-c("analysis_sample_rate", 
                "audio_md5", 
                "end_of_fade_in", 
                "analyzer_version", 
                "genre", 
                "track_7digitalid", 
                "key_confidence", 
                "mode_confidence", 
                "start_of_fade_out"))
    artist <- song %>% 
      select(starts_with("artist"))
    song <- song %>% 
      select(-starts_with("artist"))
    dbWriteTable(con, 
                 "songs", 
                 value = song, 
                 append = TRUE, 
                 row.names = FALSE)
    dbWriteTable(con, 
                 "artists", 
                 value = artist, 
                 append = TRUE, 
                 row.names = FALSE)
  }
  
  # extract artist data
  if (length(h5f$metadata$artist_terms) > 0) 
  {
    metadata.artist.terms <- data.frame(artist = h5f$metadata$songs$artist_id, 
                                        term = h5f$metadata$artist_terms, 
                                        term_freq = h5f$metadata$artist_terms_freq, 
                                        term_weight = h5f$metadata$artist_terms_weight)
    dbWriteTable(con, 
                 "metadata_artist_terms", 
                 value = metadata.artist.terms, 
                 append = TRUE, 
                 row.names = FALSE)
  }
  if (length(h5f$metadata$similar_artists) > 0)
  {
    metadata.artist.similar <- data.frame(artist1 = h5f$metadata$songs$artist_id,
                                          artist2 = h5f$metadata$similar_artists)
    dbWriteTable(con, 
                 "metadata_artist_similar", 
                 value = metadata.artist.similar, 
                 append = TRUE, 
                 row.names = FALSE)
  }
  if (length(h5f$musicbrainz$artist_mbtags) > 0) 
  {
    musicbrainz.artist.mbtags <- data.frame(artist = h5f$metadata$songs$artist_id, 
                                            tag = h5f$musicbrainz$artist_mbtags, 
                                            tag_count = h5f$musicbrainz$artist_mbtags_count)
    dbWriteTable(con, 
                 "musicbrainz_artist_mbtags", 
                 value = musicbrainz.artist.mbtags, 
                 append = TRUE, 
                 row.names = FALSE)
  }

  # close h5 file
  H5Fclose(h5f)
  H5garbage_collect()
  rm(h5f, 
     metadata.artist.similar, 
     metadata.artist.terms, 
     musicbrainz.artist.mbtags, 
     song)
}


## disconnect database
dbDisconnect(con)
dbUnloadDriver(drv)


## delete processed h5 files
for (h5 in list.of.files[1:batch.size]) {
  file.remove(paste(base.path, 
                    h5, 
                    sep = "/"))
}