// 2023 Jimmy W. Hough Jr.
// Based on Madmachine 7 Segment project code
// Uses my lib modification of my fork of MadBoards
// to separate out conditional compilation of pin IDs.

import SwiftIO
import SwiftIOBoard // | SwiftIOFeather

final class Segwayment {

    fileprivate static let aPin = DigitalOut(Id.D8)
    fileprivate static let bPin = DigitalOut(Id.D7)
    fileprivate static let cPin = DigitalOut(Id.D6)
    fileprivate static let dPin = DigitalOut(Id.D5)
    fileprivate static let ePin = DigitalOut(Id.D4)
    fileprivate static let fPin = DigitalOut(Id.D2)
    fileprivate static let gPin = DigitalOut(Id.D3)

    public enum Segment: CaseIterable {
       
        case a,b,c,d,e,f,g
        
        public func nextSegment() -> Segment {
            switch self {
                case .a:
                return .b
                case .b:
                return .c
                case .c:
                return .d
                case .d:
                return .e
                case .e:
                return .f
                case .f:
                return .g
                case .g:
                return .a
            }
        }

        public func priorSegment() -> Segment {
            switch self {
                case .a:
                return .g
                case .b:
                return .a
                case .c:
                return .b
                case .d:
                return .c
                case .e:
                return .d
                case .f:
                return .e
                case .g:
                return .f
            }
        }

        public var segmentPin:DigitalOut {
             switch self {
                case .a:
                return Segwayment.aPin
                case .b:
                return Segwayment.bPin
                case .c:
                return Segwayment.cPin
                case .d:
                return Segwayment.dPin
                case .e:
                return Segwayment.ePin
                case .f:
                return Segwayment.fPin
                case .g:
                return Segwayment.gPin
            }
        }
        
        func toggle() {
            segmentPin.toggle()
        }

        func write(_ b:Bool) {
            segmentPin.write(b)
        }
    }

    public let ledSegments:[Segment] = [.a, .b, .c, .d, .e, .f, .g]

    public var currentPattern:UInt8 = 0
   
   /*
    The display is represented by one byte.
    Each segment is assigned a bit with the most significant (bit 8) being ignored.

                      A
                     ***
                   *     *
                 F *  G   * B
                   * *** *
                 E *     * C
                   *     *
                     ***  * H?
                      D   
            7 Segment Pattern Table
    ____________________________________________
    Bit:     8   7   6   5   4   3   2   1
    ____________________________________________
    Seg:    n/a  G   F   E   D   C   B   A

        0 ABCDEF
        1 BC
        2 ABDEG
        3 ABCDG
        4 BCFG
        5 ACDFG
        6 ACDEFG
        7 ABC
        8 ABCDEFG
        9 ABCDFG
        A ABCEFG
        b 
        C
        d
        E
        F
   */

    public let decimalDigitPatternTable: [UInt8] = [
            0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110, 
            0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01101111
    ]

    public var hexDigitPatternTable: [UInt8] {
        let extra:[UInt8] = [
        
            0b01110111, // A
            0b01111100, // b
            0b00111001, // C
            0b01011110, // d
            0b01111001, // E
            0b01110001, // F

        ]

        return decimalDigitPatternTable + extra   
    }

    public func applyPattern(_ p:UInt8) {
        // Get the value of each bit to determine whether the relevant segment is on or off.
        for i in 0..<7 {
            let state = (p >> i) & 0x01
            if state == 0 {
                ledSegments[i].write(true) // turns segment off
            } else {
                ledSegments[i].write(false) // turns segment on
            }   
        }
        // Once the pattern is set, mark it as current
        currentPattern = p
    }

    public func printDecimalDigit(_ number: Int) {
        // Get the last digit of the number.
        let num = number % 10
        let pattern = decimalDigitPatternTable[num] 
        applyPattern(pattern)
    }

    public func printHexDigit(_ hex:Int) {
        // get the last digit of the number in base 16
        let num = hex % 16
        let pattern = hexDigitPatternTable[num] 
        applyPattern(pattern)
    }
}