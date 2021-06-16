pleth
=====

>  Jefe : I have put many beautiful pinatas in the storeroom, each of them filled with little suprises.
> 
> El Guapo : Many pinatas?
> 
> Jefe : Oh yes, many!
> 
> El Guapo : Would you say I have a plethora of pinatas?
> 
> Jefe : A what?
> 
> El Guapo : A *plethora*.
> 
> Jefe : Oh yes, you have a plethora.
> 
> El Guapo : Jefe, what is a plethora? 

**pleth** is a photo management tool I built, that only I (and my
wife) use.  Files are stored on-disk, metadata is stored in redis,
and there's a Dancer application server that provides an API for
the front-end to manage the data in the back-end.

Redis Schema
------------

Images are tracked by an ID, which is just the SHA-256 checksum of
the image file's contents.  This helps to ensure that we don't
ingest _identical_ files,  It is, however, important to note that
the same _image_ may have different EXIF data, causing the file
checksums to differ.  This is an acceptable deficiency.

Redis SETs keep track of the status of image objects:

  - **scanned** - Image objects that have been reviewed by a human
    and (presumably) tagged and kept, purposefully.

  - **unscanned** - Image objects that have not yet undergone
    review.  All newly-imported image objects go into this set /
    status first.

Each Image object exists as a serialized JSON object, kept in its
own key, using the following naming convention:

    ob:$IMAGE_OBJECT_ID

(These are the actual values that are stored as members of the
`scanned` and `unscanned` sets)

An Image Object contains the following top-level keys:

  - `file` is the full path to the image, relative to the URL
    and the `$PLETH_ROOT` environment variable.

  - `sha256` is the full SHA-256 checksum of the file.  Right now,
    this is identical to the ID used as the Redis key.

  - `fs` contains filesystem information, notably size and
    modification times.

  - `exif` contains the extracted EXIF metadata from the image.


API (Sketch)
------------

```
GET /v1/next
200 OK
{
  "total": 14562,
  "seen": 150,
  "obs": [
    {
      "id": "... sha256sum ...",
      "url": "/a/relative/url",
      "exif": {
        /* exif data, raw-ish */
      },
      "fs": {
        /* filesystem data */
      }
    }
  ]
}

========================================================

POST /v1/scan

200 OK
{
  "total": 15782,
  "seen": 150
}

========================================================

POST /v1/ob/:id
{
  "tags": ["a", "list", "of", "tags"],
  "metadata": {
    "keyed": "metadata"
  }
}

204 No Content

========================================================

DELETE /v1/ob/:id
204 No Content
```


Co-located Filesystem Metadata
------------------------------

Eventually, the API will support "compacting" the Redis data by
moving the metadata (tags and whatnot) into files, stored on-disk
next to the images themselves.  The idea here being that we can
organize images by primary categorization, and fill in the
cross-cutting attributes using tags, specified on a per-directory
and per-file basis.

Here's an example meta.yml file I dreamt up:

    ---
    autoTags:
      - (YYYY)
      - (MMM) (YYYY)
    tags:
      - Finn
      - Finn & Willow
      - Christmas 2019
    files:
      foo.jpg:
        tags:
          - Highlight Reel
