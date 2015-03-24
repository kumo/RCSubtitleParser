# RCSubtitleParser
Subtitle parser in Swift

## Example code

Assuming that the following subtitles exists:

````
1
00:00:12,000 --> 00:00:15,123
This is the first subtitle

2
00:00:16,000 --> 00:00:18,000
Another subtitle demonstrating tags:
<b>bold</b>, <i>italic</i>, <u>underlined</u>
<font color="#ff0000">red text</font>

3
00:00:20,000 --> 00:00:22,000  X1:40 X2:600 Y1:20 Y2:50
Another subtitle demonstrating position.
````

The following code will parse the subtitles:

```Swift
var srt_text = "1\n00:00:12,000 --> 00:00:15,123\nThis is the first subtitle\n\n2\n00:00:16,000 --> 00:00:18,000\nAnother subtitle demonstrating tags:\n<b>bold</b>, <i>italic</i>, <u>underlined</u>\n<font color='#ff0000'>red text</font>\n\n3\n00:00:20,000 --> 00:00:22,000  X1:40 X2:600 Y1:20 Y2:50\nAnother subtitle demonstrating position.\n"

if let subtitle = RCSubtitleFile(text: srt_text) {
    println("There are \(subtitle.subtitles.count) subtitles and it lasts \(subtitle.length) seconds")
} else {
    println("Couldn't parse subtitle")
}
````
