<img src="./Images/Canvas.png" width='75px' height='75px'></img>
# Canvas 2
<b><i>Canvas 2</i></b> is the updated version of my older iOS library, [Canvas](https://github.com/Authman2/Canvas)! While the first version uses mostly built in constructs from Core Graphics, this new version takes full advantage of the Metal 2 API. This means that Canvas can now support a wider range of features and do so more efficiently by taking advantage of the GPU.

## Features
- **Canvas**: A view that allows for drawing on the screen.
- **Tools**: Play around with different tools such as the pencil, eraser, line, rectangle, and ellipse.
- **Layers**: Create multiple layers on the canvas that can be removed, locked, swapped, etc.
- **Brushes**: Register different brushes on the canvas and swap between them at any time.
- **Textures**: Each brush supports a texture property so that you can customize your paint strokes based on your choice of image.
- **Events**: Keep track of when certain actions occur on the canvas by implementing the CanvasEvents protocol.
- **Undo/Redo/Clear**: Add custom undo and redo actions, and clear the canvas as well as specific layers.

## In Progress
- **Selection/Eyedropper/Fill**: Tools to move elements around the canvas, pick colors from a given pixel, and fill a particular area with color.
- **Export**: Export your canvas images to different formats.
<br></br>

# Installation
Will soon be available via Cocoapods!
<br></br>

# Author
- Year: 2020
- Tools: Swift, MetalKit
- Created By: Adeola Uthman
<br></br>

# License
Canvas is available under the MIT license. See the LICENSE file for more info.
