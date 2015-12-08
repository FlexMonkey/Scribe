# Scribe
##### _Handwriting and Stroke Recognition in Swift_

##### _Companion project to: http://flexmonkey.blogspot.co.uk/2015/12/scribe-handwriting-recognition.html_

With the recent arrival of my Apple Pencil my thoughts have turned to handwriting and stroked gesture recognition. There's already an excellent handwriting recognition framework in Swift, DBPathRecognizer, from Didier Brun, but my version uses a different technique. While Didier's uses path recognition, mine is more akin to matching two images.

The main advantage to my approach is that the user can construct a letter in any order. For example, an 'E' could be formed by drawing the three horizontal bars and the vertical bar as separate element, it could be formed by drawing a "C" shape and adding the missing central horizontal bar, or it could be formed by drawing an "L" shape and adding the other two horizontal bars as a "C" with the vertical part overlapping the existing vertical bar. 

On the downside, that freedom requires more learning. You can see in my Patterns structure the number of samples I've taken to get the demo working. 

## Encoding a User's Gesture

My ScribeView component extends a UIView and is responsible for encoding a user's strokes and invoking a method on its ScribeViewDelegate when a gesture has finished. I use the standard touchesBegan() and touchesMoved() functions to calculate the gesture's bounding box and store all the touch locations (of course, I'm using the coalesced touches):

    for touch in coalescedTouches
    {
        let locationInView = touch.locationInView(self)
        
        strokePoints.append(locationInView)
        bezierPath.addLineToPoint(locationInView)
        
        minX = min(locationInView.x, minX)
        minY = min(locationInView.y, minY)
        
        maxX = max(locationInView.x, maxX)
        maxY = max(locationInView.y, maxY)
    }

Because a single gesture may consist of more that one touch, in the touchesEnded(), I schedule a timer for 0.3". If during this period, a new touch begins, that timer is invalidated and the data from the new touch is appended to the existing gesture.

If, however, the timer completes, I invoke handleGesture() and this is where the interesting stuff happens.

First of all, using the minimum and maximum coordinates of the touch, I calculate the width and height of the bounding box:

    let gestureWidth = abs(minX - maxX)
    let gestureHeight = abs(minY - maxY)

I want the gesture to be defined in an 8 x 8 grid, so with cellCount defined as 8, I calculate the size of the cells on the screen:

    let cellWidth = max(gestureWidth / CGFloat(cellCount - 1), 1)
    let cellHeight = max(gestureHeight / CGFloat(cellCount - 1), 1)

Then create a two dimensional array of Booleans to hold my data:

    var cells = [[Bool]](count: cellCount, repeatedValue: [Bool](count: cellCount, repeatedValue: false))

I can now iterate over the stored stroke points and based on the position of the top left corner of the bounding box and cell sizes, I can set the values in my cells array to be true where a touch location has passed though a cell. If effect, I'm transforming the gesture, whatever its size and aspect ratio, into a normalised 8 x 8 square.

The reason I chose 8 x 8 is that those 64 Boolean values fit perfectly into a UInt64 which is basically a hash for the gesture and used to match against my library of known gestures in Patterns. So, since cells is an array of arrays, I use flatMap()  to flatten it then reduce() with a bit-shift to create that big unsigned integer that represents the 8 x 8 array:

    let strokeResult = cells.flatMap({ return $0 }).reduce(UInt64(0))
    {
        ($0 << 1 | ($1 ? 1 : 0))
    }

The next step is to match that result against my library. To do that I perform a logical 'and' against the result of the user's stroke result and the UInt64 of my known strokes and get the population count, or popcount, of that. Using reduce() again, I pick the item with the highest popcount:

    let bestMatch = patterns.reduce((UInt64(0), UInt64(0), ""))
    {
        let popcount = ($1.0 & strokeResult).popcount()
        
        return popcount > $0.0 ? (popcount, $1.0, $1.1) : $0
    }

To help me create the library, I have function printToConsole() which prints an ASCII version of the array and its UInt64 value:

## Conclusion

This was only a few hours of tinkering, but I think is a nice grounding for simple gesture recognition using Swift.

As always, the source code for this project is available at my GitHib repository here. Enjoy!
