locals {
  files_root = "${path.module}/html"

  // So the MIME types aren't transferred so we use this map of file extensions - going forward this is less than ideal
  ext_to_content_type = {
    "html" = "text/html"
    "htm" = "text/html"
    "ico" = "image/vnd.microsoft.icon"
    "png" = "image/png"
    "css" = "text/css"
    "jpg" = "image/jpeg"
    "jpeg" = "image/jpeg"
    // There's a decent list here: https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Common_types
  }

  // Collate files to upload and the matching content_type
  files_and_types = {
    for file in fileset(local.files_root, "**") :
      file =>
        lookup(
          local.ext_to_content_type,
          element(split(".", basename(file)), length(split(".", basename(file))) - 1)
        )
  }
}