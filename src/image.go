package main

import (
	"C"
	"bytes"
	"image"
	"image/png"
	"log"

	"encoding/base64"

	"golang.org/x/image/draw"
)

//export imageConverts
func imageConverts(in *C.char) *C.char {
	input := C.GoString(in)
	log.Println("decoding bytes")
	log.Println("starting convertion")
	bys, err := base64.StdEncoding.DecodeString(input)
	if err != nil {
		log.Fatalf("error while decode image %v", err)
	}
	log.Println("decoding bytes")
	img, err := png.Decode(bytes.NewReader(bys))
	if err != nil {
		log.Fatalf("error while decode image %v", err)
	}
	resizeImg := image.NewRGBA(image.Rect(0, 0, img.Bounds().Max.X/2, img.Bounds().Max.Y/2))

	// Resize:

	
	draw.NearestNeighbor.Scale(resizeImg, resizeImg.Rect, img, img.Bounds(), draw.Over, nil)
	outBts := createBitImage(resizeImg)
	out := base64.StdEncoding.EncodeToString(outBts)
	log.Println("out", out)
	return C.CString(out)
}

//export enforce_binding
func enforce_binding() {}

func main() {}

func createBitImage(imgx image.Image) []byte {
	log.Println(imgx.Bounds().Max)
	result := []byte{}

	dx := imgx.Bounds().Dx()
	dy := imgx.Bounds().Dy()
	bitBuild := byte(0b0)
	for x := 0; x < dx; x++ {
		for y := 0; y < dy; y++ {
			c := imgx.At(y, x)
			r, g, b, _ := c.RGBA()
			bPos := y % 8
			add := byte(0b1)
			bitBuild = bitBuild << 1
			if r+g+b/3 > 100 {

				bitBuild = bitBuild | add
			}
			if bPos == 7 || y == dy-1 {
				if y == dy-1 {
					bitBuild = bitBuild << (7 - bPos)
				}
				result = append(result, bitBuild)
				log.Println(bitBuild)
				bitBuild = 0b0
			}
		}
	}
	return result
}
