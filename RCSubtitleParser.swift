extension String {
    /** If the string represents an double that fits into an Double, returns the corresponding double. This accepts strings that match the regular expression "[+-]?(?:\d*[\.,])?\d+" only. **/
    func toDouble() -> Double? {

        let pattern = "^[+-]?(?:\\d*[\\.,])?\\d+$"

        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.dotMatchesLineSeparators)

            let numberOfMatches = regex.numberOfMatches(in: self, options: [], range: NSMakeRange(0, self.count))

            if numberOfMatches != 1 {
                return nil
            }

            let dottedString = self.replacingOccurrences(of: ",", with: ".", options: String.CompareOptions.literal, range: nil)

            return strtod(dottedString, nil)
        } catch {
            return 0.0
        }
    }
}

struct Time {
    var timeInSeconds: Double
    init(fromMilliseconds milliseconds: Int) {
        timeInSeconds = Double(milliseconds) / 1000.0
    }
    init?(fromTimeStamp timeStamp: String) {
        timeInSeconds = 0.0

        var components = timeStamp.components(separatedBy: ":")

        if let seconds = components.last?.toDouble() {
            timeInSeconds = seconds

            components.removeLast()
            if let last = components.last, let minutes = Int(last) {
                timeInSeconds += Double(minutes) * 60.0

                components.removeLast()
                if let last = components.last, let hours = Int(last) {
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
        var type = identifyFromText(text: text)

        if type == .Unknown {
            return nil
        } else if type == .SubRip {
            if !parseSubRip(text: text) {
                return nil
            }
        }
    }

    private func parseSubRip(text: String) -> Bool {
        let subs = text.components(separatedBy: "\n\n")

        for sub in subs {
            let rows = sub.components(separatedBy: CharacterSet.newlines)

            if rows.count < 3 {
                return false
            }

            if let id = Int(rows[0]) {
                let times = rows[1].components(separatedBy: " --> ")

                if times.count < 2 {
                    return false
                }

                if let startTime = Time(fromTimeStamp: times[0]) {
                    if let endTime = Time(fromTimeStamp: times[1].components(separatedBy: " ")[0]) {

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
        let scanner = Scanner(string: text)

        if scanner.scanInt(nil) {
            var timeLine:NSString?

            if scanner.scanCharacters(from: CharacterSet(charactersIn: "0123456789:.,-> "), into: &timeLine) {

                if let timeLine = timeLine {
                    if timeLine.components(separatedBy: " --> ").count == 2 {
                        return .SubRip
                    }
                }
            }
        }

        return .Unknown
    }
}
