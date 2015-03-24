extension String {
    /** If the string represents an double that fits into an Double, returns the corresponding double. This accepts strings that match the regular expression "[+-]?(?:\d*[\.,])?\d+" only. **/
    func toDouble() -> Double? {
        
        let pattern = "^[+-]?(?:\\d*[\\.,])?\\d+$"
        
        var error: NSError? = nil
        
        if let regex = NSRegularExpression(pattern: pattern, options: NSRegularExpressionOptions.DotMatchesLineSeparators, error: &error) {
            
            let numberOfMatches = regex.numberOfMatchesInString(self, options: nil, range: NSMakeRange(0, countElements(self)))
            
            if numberOfMatches != 1 {
                return nil
            }
            
            let dottedString = self.stringByReplacingOccurrencesOfString(",", withString: ".", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            return strtod(dottedString, nil)
        }
        
        return 0.0
    }
}

struct Time {
    var timeInSeconds: Double
    init(fromMilliseconds milliseconds: Int) {
        timeInSeconds = Double(milliseconds) / 1000.0
    }
    init?(fromTimeStamp timeStamp: String) {
        timeInSeconds = 0.0
        
        var components = timeStamp.componentsSeparatedByString(":")
        
        if let seconds = components.last?.toDouble() {
            timeInSeconds = seconds
            
            components.removeLast()
            if let minutes = components.last?.toInt() {
                timeInSeconds += Double(minutes) * 60.0
                
                components.removeLast()
                if let hours = components.last?.toInt() {
                    timeInSeconds += Double(hours) * 3600.0
                }
            }
        } else {
            return nil
        }
    }
    init(_ seconds: Double) {
        timeInSeconds = seconds
    }
}

class RCSubtitleFile {
    var subtitles: [Subtitle] = []
    
    var length:Double {
        get {
            if subtitles.count > 0 {
                return subtitles.last!.end.timeInSeconds
            } else {
                return 0.0
            }
        }
    }
    
    enum SubtitleType {
        case SubRip, Unknown
    }

    struct Subtitle {
        var start: Time, end: Time
        var text: [String] = []
        
        var length: Double {
            get {
                return end.timeInSeconds - start.timeInSeconds
            }
        }
    }
    
    init?(text: String) {
        var type = identifyFromText(text)
        
        if type == .Unknown {
            return nil
        } else if type == .SubRip {
            if !parseSubRip(text) {
                return nil
            }
        }
    }
    
    private func parseSubRip(text: String) -> Bool {
        let subs = text.componentsSeparatedByString("\n\n")
        
        for sub in subs {
            let rows = sub.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet())
            
            if rows.count < 3 {
                return false
            }
            
            if let id = rows[0].toInt() {
                let times = rows[1].componentsSeparatedByString(" --> ")
                
                if times.count < 2 {
                    return false
                }
            
                if let startTime = Time(fromTimeStamp: times[0]) {
                    if let endTime = Time(fromTimeStamp: times[1].componentsSeparatedByString(" ")[0]) {
                        
                        let text = Array(rows[2...rows.count-1])
                        let subtitle = Subtitle(start: startTime, end: endTime, text: text)
                        
                        subtitles.append(subtitle)
                    }
                }
            }
        }
        
        return true
    }
    
    func identifyFromText(text: String) -> SubtitleType {
        var scanner = NSScanner(string: text)
        
        if scanner.scanInt(nil) {
            var timeLine:NSString?
            
            if scanner.scanCharactersFromSet(NSCharacterSet(charactersInString: "0123456789:.,-> "), intoString: &timeLine) {
                
                if let timeLine = timeLine {
                    if timeLine.componentsSeparatedByString(" --> ").count == 2 {
                        return .SubRip
                    }
                }
            }
        }
        
        return .Unknown
    }
}
