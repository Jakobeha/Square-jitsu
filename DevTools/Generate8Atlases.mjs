#! /usr/bin/env node --experimental-modules
import glob from "glob"
import cp from "child_process"
import path from "path"
import rimraf from "rimraf"
import fs from "fs"

const imagesDir = "/Users/Jakob/Desktop/Projects/Square-jitsu/Square-jitsu/Resources/Tiles"

function process8AtlasesOfType(typeName, typeComposeImplementation) {
    console.log(`Processing 8-${typeName}s...`)
    let inFileSuffix = `-8${typeName}.png`
    let inFilePaths = glob.sync(`${imagesDir}/*${inFileSuffix}`, null)
    for (const inFilePath of inFilePaths) {
        const inFileName = path.basename(inFilePath)
        const name = inFileName.substring(0, inFileName.length - inFileSuffix.length)
        const outDirPath = `${imagesDir}/${name}`

        console.log(`Processing 8-${typeName} ${name}...`)

        // Create the directory of processed images
        rimraf.sync(outDirPath)
        fs.mkdirSync(outDirPath)

        // First split the image into atomic chunks
        // (these are temporary and we combine them in different ways to form the final images)
        cp.execSync(`convert ${inFilePath} +gravity -crop 96x96 ${outDirPath}/temp_%d.png`)

        function composeImage(patternFromAdjacents, partGrid) {
            cp.execSync(`convert \\
              \\( ${outDirPath}/temp_${partGrid[0][0]}.png ${outDirPath}/temp_${partGrid[0][1]}.png +append \\) \\
              \\( ${outDirPath}/temp_${partGrid[1][0]}.png ${outDirPath}/temp_${partGrid[1][1]}.png +append \\) \\
            -append ${outDirPath}/${name}_${patternFromAdjacents}.png`)
        }

        typeComposeImplementation(composeImage)

        const tempFilePaths = glob.sync(`${outDirPath}/temp_*.png`, null)
        for (const tempFilePath of tempFilePaths) {
            fs.unlinkSync(tempFilePath)
        }
        console.log(`Done ${name}`)
    }
    console.log(`Done 8-${typeName}s`)
}
console.log("Processing...")
process8AtlasesOfType("Square", composeImage => {
    composeImage("00000000+", [[0, 5], [18, 23]])
    composeImage("00000001", [[1, 5], [19, 23]])
    composeImage("01000000", [[6, 11], [18, 23]])
    composeImage("00010000", [[0, 4], [18, 22]])
    composeImage("00000100", [[0, 5], [12, 17]])
    composeImage("00000111", [[1, 5], [14, 17]])
    composeImage("11000001", [[8, 11], [19, 23]])
    composeImage("01110000", [[12, 9], [18, 22]])
    composeImage("00011100", [[0, 4], [12, 15]])
    composeImage("00010001", [[1, 4], [19, 22]])
    composeImage("01000100", [[6, 11], [12, 17]])
    composeImage("00010101", [[1, 4], [20, 21]])
    composeImage("01000101", [[2, 11], [20, 17]])
    composeImage("01010001", [[2, 3], [19, 22]])
    composeImage("01010100", [[6, 3], [12, 21]])
    composeImage("00011101", [[1, 4], [20, 15]])
    composeImage("01000111", [[2, 11], [14, 17]])
    composeImage("11010001", [[8, 3], [19, 22]])
    composeImage("01110100", [[6, 9], [12, 21]])
    composeImage("00010111", [[1, 4], [14, 21]])
    composeImage("11000101", [[8, 11], [20, 17]])
    composeImage("01110001", [[2, 9], [19, 22]])
    composeImage("01011100", [[6, 3], [12, 15]])
    composeImage("00011111", [[1, 4], [14, 15]])
    composeImage("11000111", [[8, 11], [14, 17]])
    composeImage("11110001", [[8, 9], [19, 22]])
    composeImage("01111100", [[6, 9], [12, 15]])
    composeImage("01010101", [[2, 3], [20, 21]])
    composeImage("01010111", [[2, 3], [20, 15]])
    composeImage("11010101", [[8, 3], [20, 21]])
    composeImage("01110101", [[2, 9], [20, 21]])
    composeImage("01011101", [[2, 3], [14, 21]])
    composeImage("01110111", [[2, 9], [20, 15]])
    composeImage("11011101", [[8, 3], [14, 21]])
    composeImage("01011111", [[2, 3], [14, 15]])
    composeImage("11010111", [[8, 3], [20, 15]])
    composeImage("11110101", [[8, 9], [20, 21]])
    composeImage("01111101", [[2, 9], [14, 21]])
    composeImage("01111111", [[2, 9], [14, 15]])
    composeImage("11011111", [[8, 3], [14, 15]])
    composeImage("11110111", [[8, 9], [20, 15]])
    composeImage("11111101", [[8, 9], [14, 21]])
    composeImage("11111111", [[8, 9], [14, 15]])
})
process8AtlasesOfType("Diamond", composeImage => {
    composeImage("0000", [[1, 2], [13, 14]])
    composeImage("1000", [[13, 14], [12, 15]])
    composeImage("0100", [[0, 4], [12, 8]])
    composeImage("0010", [[0, 3], [1, 2]])
    composeImage("0001", [[7, 3], [11, 15]])
    composeImage("1100", [[8, 9], [12, 13]])
    composeImage("0110", [[0, 1], [4, 5]])
    composeImage("0011", [[2, 3], [6, 7]])
    composeImage("1001", [[10, 11], [14, 15]])
    composeImage("1010", [[5, 6], [9, 10]])
    composeImage("0101", [[5, 6], [9, 10]])
    composeImage("0111", [[2, 1], [9, 10]])
    composeImage("1011", [[5, 11], [9, 7]])
    composeImage("1101", [[5, 6], [14, 13]])
    composeImage("1110", [[8, 6], [4, 10]])
    composeImage("1111", [[5, 6], [9, 10]])
})
console.log("Done")
