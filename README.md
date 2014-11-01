pubimg
======

pubimg.sh

Customizing
-----------

To customize the script to your needs you can change the following variables:

* `TARGET_DIR` - the target directory in which the converted image copies will be created (default = `pubimg.out`).
* `TARGET_QUALITY` - the output quality (default = `80`).
* `DEFAULT_TARGET_SIZE` - the default target size (default = `900`).
* `TARGET_SIZE[100]` - special target size for aspect ratio 1.0 (default = `800`). You also can add more array entries for other aspect ratios.
* `WATERMARK` - path to your watermark file (default = `my_watermark.svg`).
* `WATERMARK_SIZE` - the size the watermark you get in percent (default = `50`). The watermark size will be increased or decreased automatically depending on the aspect ratio.
* `WATERMARK_OPACITY` - the opacity value for the watermark (default = `30`).
* `WATERMARK_MARGIN` - the margin the watermark should have to the image border (default = `10`).
* `WATERMARK_POS` - the watermark position (default = `southeast`)
