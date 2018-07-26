## install rhdf5 package from BioCOnductor if necessary
#source("https://bioconductor.org/biocLite.R")
#biocLite("rhdf5")
library(rhdf5)


## set base path of the h5 folder structure
base.path <- "C://Users//kgreger//Downloads//MillionSongSubset//data"

## get list of all h5 files (recursively scanning the folder structure)
list.of.files <- dir(path = base.path, 
                     pattern = "\\.h5", 
                     recursive = TRUE)

## loop through h5 files
for (h5 in list.of.files){
  # open h5 file
  h5f = H5Fopen(paste(base.path, 
                      gsub("/", 
                           "//", 
                           h5), 
                      sep = "//"))
  
  # extract song data (skipping bars, sections, segments, and tatums)
  if (length(h5f$metadata$songs$artist_id) > 0) 
  {
    song <- data.frame(h5f$analysis$songs, 
                       h5f$metadata$songs, 
                       h5f$musicbrainz$songs)
    if(!file.exists(paste0(base.path, 
                           "//msd-songs.csv"))) 
    {
      write.table(song, 
                  file = paste0(base.path, 
                                "//msd-songs.csv"), 
                  sep = "\t", 
                  append = FALSE, 
                  col.names = TRUE, 
                  row.names = FALSE)
    } else {
      write.table(song, 
                  file = paste0(base.path, 
                                "//msd-songs.csv"), 
                  sep = "\t", 
                  append = TRUE, 
                  col.names = FALSE, 
                  row.names = FALSE)
    }
  }
  
  # extract artist data
  if (length(h5f$metadata$artist_terms) > 0) 
  {
    metadata.artist.terms <- data.frame(artist = h5f$metadata$songs$artist_id, 
                                        term = h5f$metadata$artist_terms, 
                                        term_freq = h5f$metadata$artist_terms_freq, 
                                        term_weight = h5f$metadata$artist_terms_weight)
    if(!file.exists(paste0(base.path, 
                           "//msd-artist-terms.csv"))) 
    {
      write.table(metadata.artist.terms, 
                  file = paste0(base.path, 
                                "//msd-artist-terms.csv"), 
                  sep = "\t", 
                  append = FALSE, 
                  col.names = TRUE, 
                  row.names = FALSE)
    } else {
      write.table(metadata.artist.terms, 
                  file = paste0(base.path, 
                                "//msd-artist-terms.csv"), 
                  sep = "\t", 
                  append = TRUE, 
                  col.names = FALSE, 
                  row.names = FALSE)
    }
  }
  if (length(h5f$metadata$similar_artists) > 0) 
  {
    metadata.artist.similar <- data.frame(artist1 = h5f$metadata$songs$artist_id, 
                                          artist2 = h5f$metadata$similar_artists)
    if(!file.exists(paste0(base.path, 
                           "//msd-artist-similar.csv"))) 
    {
      write.table(metadata.artist.similar, 
                  file = paste0(base.path, 
                                "//msd-artist-similar.csv"), 
                  sep = "\t", 
                  append = FALSE, 
                  col.names = TRUE, 
                  row.names = FALSE)
    } else {
      write.table(metadata.artist.similar, 
                  file = paste0(base.path, 
                                "//msd-artist-similar.csv"), 
                  sep = "\t", 
                  append = TRUE, 
                  col.names = FALSE, 
                  row.names = FALSE)
    }
  }
  if (length(h5f$musicbrainz$artist_mbtags) > 0) 
  {
    musicbrainz.artist.mbtags <- data.frame(artist = h5f$metadata$songs$artist_id, 
                                            tag = h5f$musicbrainz$artist_mbtags, 
                                            tag_count = h5f$musicbrainz$artist_mbtags_count)
    if(!file.exists(paste0(base.path, 
                           "//msd-artist-mbtags.csv"))) 
    {
      write.table(musicbrainz.artist.mbtags, 
                  file = paste0(base.path, 
                                "//msd-artist-mbtags.csv"), 
                  sep = "\t", 
                  append = FALSE, 
                  col.names = TRUE, 
                  row.names = FALSE)
    } else {
      write.table(musicbrainz.artist.mbtags, 
                  file = paste0(base.path, 
                                "//msd-artist-mbtags.csv"), 
                  sep = "\t", 
                  append = TRUE, 
                  col.names = FALSE, 
                  row.names = FALSE)
    }
  }

  # close h5 file
  H5Fclose(h5f)
}