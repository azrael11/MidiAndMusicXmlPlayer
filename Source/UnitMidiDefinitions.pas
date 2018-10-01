//---------------------------------------------------------------------------
//
//  Program:     UnitMidiDefinitions.pas
//
//  Project:     MidiAndMusicXmlPlayer.exe, MidiAndMusicXmlPlayer.app
//
//  Purpose:     All common definitions for the units
//
//  Compilation: Compile with Delphi 4 (MidiAndMusicXml.dpr) or
//               Delphi Berlin (MidiAndMusicXmlPlayer.proj)
//               Lazarus (MidiAndMusicXmlPlayer.lpi)
//
//  Description: Common data structures, procedures and functions
//
//---------------------------------------------------------------------------
unit UnitMidiDefinitions;

{$ifdef FPC}
{$MODE Delphi}
{$endif}

interface

{$ifdef FPC}
{$ifdef Darwin}
uses {LCLIntf, LCLType, LMessages,} SysUtils;
{$else}
uses {LCLIntf, LCLType, LMessages,} SysUtils, MMSystem, jwawinnls, Windows, Graphics;
{$endif}
{$else}
uses  Windows,SysUtils, MMSystem;
{$endif}

//---------------------------------------------------------------------------
//
// Definitions and Limitations for the system
//
//---------------------------------------------------------------------------

const VersionTextOnly='1.77 Build 001';

{$ifdef FPC}
const VersionText=VersionTextOnly+'L';
{$else}
const VersionText=VersionTextOnly+'D';
{$endif}

const MaxFileSize = 400000;
const MaxEvents = 100000;
const MaxTexts = 5000;
const MaxTextLines = 10000;
const MaxEventsChannel = 100000;
const Channels = 16;
const Tracks = 128;
const MaxTimeSignatures = 10; // Max number of time signature
const MidiTemposMax = 255; // 255;  // Max number of tempo changes
const MaxNumberOfTimeDivision = 100000; // In XML
// Midi allows 128, but let this temporary be bigger
// (Musescore may create high numbers - but do not use them)
const MaxNumberOfInstruments = 512;
const XmlDefaultTempo = 120;
const MidiWindowWidth = 432;
const MidiVolumeMax = 127;
const MidiPanoramaMax = 127;
const MidiProgramMax = 127;
const MidiNoteLast = 127;          //// Name ????
const MidiNoteFirst = 0;
const MidiOutMaxNumDevs = 10;

// Option definitions
const NumberOfOptions = 75; // Number of options
// A magic number is used to check the option file
const OptionsMagicNumber = 746533;

// FindFirst constants
const
  SAnyMask = {$ifdef Darwin}'*'{$else}'*.*'{$endif};
  PathDelim = {$ifdef Darwin}'/'{$else}'\'{$endif};

// Special events used in playing
const SpecialMetaEventTempo = 1;
const SpecialMetaEventMeasure = 2;


var SelectableInstruments: array[0..4] of string = ('Original','Piano','Do Do','Oboe','Rhythm');

//---------------------------------------------------------------------------
//
// Record types for the midi system
//
//---------------------------------------------------------------------------

// State concerning reading the midi file
type TMidiState = (MidiStart, MidiTrackHeader, MidiTrack,
                   MidiEnd, MidiStop);

// State concerning reading the midi file parts
type TMidiSubState = (MidiSubStart, MidiSubDelta, MidiSubMetaEvent,
                      MidiSubMetaContinue, MidiSubEvent,
                      MidiSubContinue, MidiSubEnd, MidiSubStop);

// State concerning playing
type TSystemState = (MidiNotStarted,MidiStarting,MidiNoFile,MidiEmpty,
                          MidiReading, MidiUp, MidiPaused, MidiFinished,
                          MidiPlaying, MidiPositioning, MidiError);

// Only two clefs handled C and F
type TClef = (Clef_Undefined, Clef_C, Clef_F);

// Start of Midi file according to Midi Specification
type TMidiTrackHeader = record
                 MidiTrackHeader: int64;
                 MidiTrackHeaderLength: int64;
                 MidiFormat: int64;
                 MidiTracks: int64;
                 MidiTicksPerNote: int64;
                 end;

// Start of Midi file after header according to Midi Specification
type TMidiTrack = record
                 MidiTrack: int64;
                 MidiTrackLength: int64;
                 end;

// All Midi data. According to Midi Specification
type TMidiData = record
                 MidiTrackHeader: TMidiTrackHeader;
                 MidiTrack: TMidiTrack;
                 MidiCurrentTrackName: string;
                 MidiData: array[0..MaxFileSize] of byte;
                 MidiDataSelected: array[0..MaxFileSize] of byte;
                 MidiDataChannel: array[0..MaxFileSize] of byte;
                 MidiDataIndex: int64;
                 MidiDataIndexes: array[0..10000] of int64;    ////definitions
                 MidiDataIndexMax: int64;
                 ////MidiDataInstrument: array[0..Channels] of integer;
                 MidiDataProgramSet: array[0..Channels] of boolean;
                 MidiDataTempoIndex: int64;
                 // An index to the midi file for each panorama value
                 MidiDataPanoramaIndex: array[0..Channels] of integer;
                 // Use the value of scrollbars instead of the midi file
                 MidiDataPanoramaUseScrollbar: array[0..Channels] of boolean;
                 end;

// Used for some WIN32 calls (Will be converted to Pascal string)
type CString = array[1..256] of char;

// All message to the Midi-interface uses this message type (pro tempora)
type TMidiShortMessage = record
                           case integer of
                           1: (Bytes: array[0..3] of byte);
                           2: (Word: DWORD);
                         end;

type TNoteValue = MidiNoteFirst..MidiNoteLast;

type VerseNumber = 0..255;

type VerseNumbers = set of VerseNumber;


var
  FileName: string;           // Name of the midi file
  MidiData: TMidiData;    ////

  UserProfile: string;        // User profile playing midi (options)

  // Data accessed from the call back function can not be part of the object
  // Therefore this common data
  SystemState: TSystemState=MidiNotStarted;   // MidiStarting, MidiUp, MidiPlay etc.
  TextsAreInitialised: boolean=false;
{$ifndef Darwin}
  MidiOutHandle: array[0..MidiOutMaxNumDevs] of THandle;  // Handle for midi output, i.e. playing
  MidiInHandle: THandle;   //// Handle for midi input , i.e. keyboard input
  MidiOutHandleStatus: array [0..MidiOutMaxNumDevs] of integer;  // Return value from MidiOutOpen
{$endif}
  // For format 0
  //// Skulle kunne bruge format 1's buffer
  MidiEvents: array[0..MaxEvents] of TMidiShortMessage;
  MidiEventDelta: array[0..MaxEvents] of int64;
  MidiTextIndex: array[0..MaxEvents] of int64;
  MidiTextIndexLine: array[0..MaxEvents] of int64;
  MidiTextIndexPos: array[0..MaxEvents] of int64;
  MidiEventsNew: array[0..MaxEvents] of TMidiShortMessage;
  MidiTexts: array[1..MaxTexts] of string;
  MidiTextsTrack: array[1..MaxTexts] of integer;
  MidiEventDeltaNew: array[0..MaxEvents] of int64;
  MidiTextsIndex: array[0..MaxEvents] of int64;
  MidiTextsIndexNew: array[0..MaxEvents] of int64;
  MidiEventIndexIn: integer;
  MidiEventIndexOut: integer;
  MidiTextIndexIn: integer;
  MidiTextIndexOut: integer;
  // For format 1 in one buffer
  MidiEventIndexChannelInStart: array[1..Tracks] of integer;
  MidiEventIndexChannelOutStart: array[1..Tracks] of integer;
  MidiEventIndexChannelInLast: array[1..Tracks] of integer;
  MidiEventIndexChannelOutLast: array[1..Tracks] of integer;

  MidiDataRhythm: array[0..Channels] of boolean;
  MidiProgramSet: array[0..Channels] of boolean;
  // For both formats
  MidiDataChecked: array[0..Channels] of boolean;
  MidiDataPanorama: array[0..Channels] of byte;

  MidiDataPanoramaChanged: array[0..Channels] of boolean;
  MidiDataComboBoxChanged: array[0..Channels] of boolean;
  MidiDataComboBoxValue: array[0..Channels] of byte;  //// value????
  MidiDataInstrumentOrg: array[0..Channels] of byte;  //// value????
  MidiSelectNew: integer;

  MidiTrackNames: array[1..Tracks] of string;  // From 0?
  MidiChannelMap: array[1..Tracks] of integer;
  MidiTranspose: integer;
  MidiTempo: int64;
  MidiDivision: int64;
  MidiTempoProcent: int64;
  MidiBankSelect: int64;
  MidiProgress: int64;
  MidiFirstNote: boolean;
  MidiDeltaTotalIn: int64;    // For writing progress bar - input
  MidiDeltaTotalOut: int64;   // For writing progress bar - output
  MidiCycleStartMark: int64;
  MidiCycleStartTime: int64;
  MidiCycleStartTempo: int64;
  MidiCycleEndmark: int64;
  MidiTimerRunning: boolean;
  MidiNumberOfChannels: integer;
  MidiMixerMustResize: boolean;
  MidiDataMixer: array[0..Channels] of integer;
  MidiErrors: int64;                // Number of errors. Report only the first
  MidiTempos: array[0..MidiTemposMax] of int64; //
  MidiTempoIndex: integer;
  // For info into score
  MidiTimeSignatureUpper: integer;  // Count ////
  MidiTimeSignatureLower: integer;  // Count denominator
  MidiTimeSignatureLowerExp: integer;  // Power of 2. I.e. 2 = Quarter not, 3 = eight-note
  MidiClef: array[0..Channels] of TClef;   // Clef
  MidiKeySignature: integer;                // 0 = C, 1 = 1 sharp
  MidiTest: boolean;
  MidiPositionForward: int64=0;        // Move position due to clicking on progress bar
  MidiPositionForwardNext: int64=0;        // Move position due to clicking on progress bar
  MidiPositionChange: boolean;
  MidiAutoClose: boolean;
  MidiShallClose: boolean;
  MidiSelectMax: integer;     // Number of Midi interfaces
  MidiSelect: integer;        // Midi interface selected
  MidiState: TMidiState;        // Main state reading midi file
  StartingWithParam: boolean; // Midi started with the filename as parameter
  MidiVisible: boolean;       // Tell when the start up message shall disappear
  MidiXmlFile: boolean;          // An XML-file will preserve unicode UTF8 on MAC
  Errors: int64;                // Number of errors. Report only the first
  MidiInHeader: TMidiHdr; ////array[0..255] of char; ////
  MidiInNumDevs: integer;           // Number of input devices
  MidiOutNumDevs: integer;           // Number of input devices
  ReadXmlBufferIndex: integer;    // Read 256 bytes into buffer
  ReadXmlBuf: array[0..255] of byte;
  CodePage: integer;
  PedalDown: boolean = false;            // A pedal may be used for start/stop
  PedalDownChanged: boolean = false;            // Set when changed. Shall be read
  PedalDownOld: boolean = false;            // To identify change

  LinguaHeader: string = '';
  LinguaTextPlaying: string = 'Playing';
  LinguaTextStopped: string = 'Stopped';
  LinguaTextPaused: string = 'Paused';
  LinguaTextOriginal: string = 'Original';
  LinguaTextPiano: string = 'Piano';
  LinguaTextDoDo: string = 'Do Do';
  LinguaTextOboe: string = 'Oboe';
  LinguaTextViolin: string = 'Violin';
  LinguaTextRhythm: string = 'Rhythm';
  LinguaTextLoading: string = 'Loading';

  LinguaTextAnSupportedEventWasEncountered: string = 'An unsupported event was encounted';
  LinguaTextDoesNotExistInDirectory: string = 'does not exist in directory';
  LinguaTextPlayMidiAndMusicXmlFiles: string = 'Play Midi and MusicXml files';
  LinguaTextThereAreNoMidiDevicesInstalled: string = 'There are no Midi devices installed';
  LinguaTextNoMidiDevicesArePresent: string = 'No midi devices are present';
  LinguaTextCouldNotOpenFile: string = 'Could not open file';
  LinguaTextAcousticGrandPiano: string = 'Acoustic Grand Piano';
  //// and many more instruments ....

  LinguaTextCopyReturnedErrorCode: string = 'Copy MidiAndMusicXmlPlayer.exe returned error code';
  LinguaTextRestartAsAdministratorToInstall: string = 'Restart as administrator to install (Right click)';

  LinguaTextError: string = 'Error';
  LinguaTextXmlParsingErrorInLine: string = 'Xml parsing error in line ';
  LinguaTextXmlParsingErrorIn: string = ' - Xml parsing error in ';
  LinguaTextXmlLine: string = ' line ';
  LinguaTextPitchIsMissing: string = 'Pitch is missing';
  LinguaTextPitchIsOutsideRange: string = 'Pitch is outside range';
  LinguaTextPartNumberIsOutOfRange: string = 'PartNumber is out of Range(';
  LinguaTextTooManyNotes: string = 'Too many notes';
  LinguaTextNoXmlHeaderFoundBut: string = 'No Xml Header found but "';
  LinguaTextPartNumber: string = 'Part number ';
  LinguaTextIsMissing: string = ' is missing';
  LinguaTextXmlErrorAfterChordNoPitchNorPause: string = 'Xml Error: after <chord/> no pitch nor pause';
  LinguaTextIncorrectMusicXmlFile: string = 'Incorrect MusicXml file: Reading Xml file ended in state ';
  LinguaTextStarting: string = 'Starting';

  // NYE!!!!
  LinguaTextNoteValue: string = 'Note value';
  LinguaTextUnknownDefinition: string = 'Unknown definition (';
  LinguaTextExpectedXmlStateEnd: string = '(Expected XmlStateEnd)';

  MidiMeasureNumberDisplay: integer = 0;


function PowerOfTwo(p: integer): integer;
function PascalString(s1: CString): string;
function StringToInt(s: string): integer;
procedure SaveMidiData;


{$ifdef FPC}
function GetCodePage: integer;
{$else}
function UniToCodepage(i: integer): char;
{$endif}


{$ifdef Darwin}
function AnsiToUnicodeString(m: string): string;
{$endif}

implementation

//---------------------------------------------------------------------------
//
//     Function: PowerOfTwo
//
//     Purpose: The convert a number to power of two (exponential function)
//
//     Parameters: p = the number
//
//     Returns:    2 ** p
//
//     Notes:  none
//
//---------------------------------------------------------------------------

function PowerOfTwo(p: integer): integer;

var i: integer;   // Loop
    r: integer;   // Result

  begin
  r:=1;
  for i:=1 to p do r:=r*2;    //// Rather r:=1 shl p;
  PowerOfTwo:=r;
  end;


//---------------------------------------------------------------------------
//
//     Function: StringToInt
//
//     Purpose: Convert from string to integer but do alway deliver a
//              value to avoid errors while changing edit boxes.
//
//     Parameters: s = the string
//
//     Returns:    The converted integer value. zero if errors
//
//     Notes:  none
//
//---------------------------------------------------------------------------

function StringToInt(s: string): integer;

var i: integer;
    minus: boolean;
    n: integer;

  begin
  minus:=false;
  n:=0;
  for i:=1 to length(s) do if s[i]='-' then
    minus:=true
  else if s[i] in ['0'..'9'] then n:=10*n+ord(s[i])-ord('0');
  if minus then n:=-n;
  StringToInt:=n;
  end;

//---------------------------------------------------------------------------
//
//     Function: PascalString
//
//     Purpose: Convert a null terminated string to Pascal string.
//
//     Parameters: s1 = The C string (null terminated)
//
//     Returns:    A Pascal string
//
//     Notes:  none
//
//---------------------------------------------------------------------------

function PascalString(s1: CString): string;

var s2: string;
    i: integer;

  begin
  s2:='';
  i:=1;
  while s1[i]<>chr(0) do
    begin
    s2:=s2+s1[i];
    inc(i);
    end;
  PascalString:=s2;
  end;

{$ifdef Darwin}
//---------------------------------------------------------------------------
//
//     Function:      UniToCodepage
//
//     Purpose:       To convert a single character to Code Page value
//
//     Parameters:    i = the UniCode character
//
//     Returns:       The code page character (one 8 bit char)
//
//     Note:          DUBBEL!!!! ANDEN FINNS I UNITXML ////
//
//---------------------------------------------------------------------------

function CodepageToUtf8(i: integer): string;

//// Ikke komplet !!!!
  begin
    case (i) of
    32..127:
      CodepageToUtf8:=chr(i);

    128:
      CodepageToUtf8:=chr(195)+chr(135); // �
    133:
      CodepageToUtf8:=chr(195)+chr(160); // �
    135:
      CodepageToUtf8:=chr(195)+chr(167); // �
    137:
      CodepageToUtf8:=chr(195)+chr(171); // �
    139:
      CodepageToUtf8:=chr(195)+chr(175); // �
    140:
      CodepageToUtf8:=chr(195)+chr(174); // �
    141:
      CodepageToUtf8:=chr(195)+chr(172); // �

    147:
      CodepageToUtf8:=chr(195)+chr(180); // �
    149:
      CodepageToUtf8:=chr(195)+chr(178); // �
    150:
      CodepageToUtf8:=chr(195)+chr(187); // �
    151:
      CodepageToUtf8:=chr(195)+chr(185); // �

    152:
      CodepageToUtf8:=chr(195)+chr(191); // �
    164:
      CodepageToUtf8:=chr(195)+chr(177); // �
    165:
      CodepageToUtf8:=chr(195)+chr(145); // �
    182:
      CodepageToUtf8:=chr(195)+chr(130); // �
    183:
      CodepageToUtf8:=chr(195)+chr(128); // �
    198:
      CodepageToUtf8:=chr(195)+chr(163); // �
    199:
      CodepageToUtf8:=chr(195)+chr(131); // �
    210:
      CodepageToUtf8:=chr(195)+chr(138); // �
    211:
      CodepageToUtf8:=chr(195)+chr(139); // �
    212:
      CodepageToUtf8:=chr(195)+chr(136); // �
    213:
      CodepageToUtf8:=chr(195)+chr(177); // i
    214:
      CodepageToUtf8:=chr(195)+chr(141); // �
    215:
      CodepageToUtf8:=chr(195)+chr(142); // �
    216:
      CodepageToUtf8:=chr(195)+chr(143); // �
    222:
      CodepageToUtf8:=chr(195)+chr(140); // �
    226:
      CodepageToUtf8:=chr(195)+chr(148); // �
    227:
      CodepageToUtf8:=chr(195)+chr(146); // �
    228:
      CodepageToUtf8:=chr(195)+chr(181); // �
    229:
      CodepageToUtf8:=chr(195)+chr(149); // �
    230:
      CodepageToUtf8:=chr(194)+chr(181); // �
    234:
      CodepageToUtf8:=chr(195)+chr(155); // �
    235:
      CodepageToUtf8:=chr(195)+chr(153); // �

    193:
      CodepageToUtf8:=chr(195)+chr(129); // '�';
    197:
      CodepageToUtf8:=chr(195)+chr(133); // '�';
    198:
      CodepageToUtf8:=chr(195)+chr(152); // '�';
    201:
      CodepageToUtf8:=chr(195)+chr(137); // '�';
    205:
      CodepageToUtf8:=chr(195)+chr(141); // '�';
    208:
      CodepageToUtf8:=chr(195)+chr(144); // '�';
    214:
      CodepageToUtf8:=chr(195)+chr(150); // '�';
    216:
      CodepageToUtf8:=chr(195)+chr(134); // '�';
    218:
      CodepageToUtf8:=chr(195)+chr(186); // '�';
    221:
      CodepageToUtf8:=chr(195)+chr(189); // '�';
    222:
      CodepageToUtf8:=chr(195)+chr(158); // '�';
    223:
      CodepageToUtf8:=chr(195)+chr(159); // '�';
    225:
      CodepageToUtf8:=chr(195)+chr(161); // '�';
    229:
      CodepageToUtf8:=chr(195)+chr(165); // '�';
    230:
      CodepageToUtf8:=chr(195)+chr(166); // '�';
    233:
      CodepageToUtf8:=chr(195)+chr(169); // '�';
    237:
      CodepageToUtf8:=chr(195)+chr(173); // '�';
    240:
      CodepageToUtf8:=chr(195)+chr(176); //'�'
    243:
      CodepageToUtf8:=chr(195)+chr(179); // '�';
    246:
      CodepageToUtf8:=chr(195)+chr(182); // '�';
    248:
      CodepageToUtf8:=chr(195)+chr(184); // '�';
    250:
      CodepageToUtf8:=chr(195)+chr(186); // '�';
    253:
      CodepageToUtf8:=chr(195)+chr(189); // '�';
    254:
      CodepageToUtf8:=chr(195)+chr(190); // '�'
    else
      begin
      if i<128 then
        CodepageToUtf8:=chr(i)
      else
        CodepageToUtf8:='?';
      end;
    end
  end;

//---------------------------------------------------------------------------
//
//     Function:      AnsiToUnicodeString
//
//     Purpose:       To convert an Ansi-string to Unicode UTF8
//
//     Parameters:    m = the Ansi string
//
//     Returns:       The unicode UTF8 string
//
//---------------------------------------------------------------------------

function AnsiToUnicodeString(m: string): string;

var r: string;
    i: integer;

  begin
  r:='';
  for i:=1 to Length(m) do
    r:=r+CodepageToUtf8(ord(m[i]));
  AnsiToUnicodeString:=r;
  end;

{////
function GetCodePage: integer;

var
 CPInfo: TCPInfo;
 CD: Cardinal;
 CharsetInfo: TCharSetInfo;
 CSN: String;

  begin
  GetCodePage:=-1;
  if GetCPInfo(CP_ACP,CPInfo) then
    begin
////    CD:=CPInfo.Codepage;
    if TranslateCharsetInfo(CD,CharsetInfo,TCI_SRCCODEPAGE) then
      begin
      CharsetToIdent(CharsetInfo.ciCharset,CSN);
      GetCodePage:=CharsetInfo.ciCharset;
      Showmessage(CPInfoEx.CodePageName+' - '+IntToStr(CharsetInfo.ciCharset)+' - '+CSN);
      end;
    end;
  end;
////}
{$endif}


{$ifdef FPC}

//---------------------------------------------------------------------------
//
//     Function:      GetCodePage
//
//     Purpose:       To read the actual code page
//
//     Parameters:    none
//
//     Returns:       The code page
//
//---------------------------------------------------------------------------

function GetCodePage: integer;

var
 CPInfoEx: TCPInfoEx;
 CD: Cardinal;
 CharsetInfo: TCharSetInfo;
 CSN: string;

begin
 If GetCPInfoEx(CP_ACP,0,CPInfoEx) then
  begin
    CD := CPInfoEx.Codepage;
    if TranslateCharsetInfo(CD,CharsetInfo,TCI_SRCCODEPAGE) then
      begin
      GetCodePage:=CharsetInfo.ciCharset;
      CharsetToIdent(CharsetInfo.ciCharset,CSN);
      MessageBox(0,Pchar(CPInfoEx.CodePageName+' - '+IntToStr(CharsetInfo.ciCharset)+' - '+CSN),'',0);
     end;
  end;
end;


//---------------------------------------------------------------------------
//
//     Function:      UniToCodepage (for Lazarus)
//
//     Purpose:       Dummy function when compiling to Lazarus
//                    Lazarus uses Utf8 and no conversion to Code Page is
//                    needed
//
//     Parameters:    utf8 = the string to be converted
//
//     Returns:       The same string
//
//     Note:          none
//
//---------------------------------------------------------------------------

function UtfToCodepage(utf8: string): string;

  begin
  UtfToCodepage:=utf8;
  end;

{$else}
// Windows

//---------------------------------------------------------------------------
//
//     Function:      UniToCodepage
//
//     Purpose:       To convert a single character to Code Page value
//                    The conversion is according to Codepage 1252
//                    Windows Latin 1(Ansi)
//
//     Parameters:    i = the UniCode character
//
//     Returns:       The code page character (one 8 bit char)
//
//     Note:          none
//
//---------------------------------------------------------------------------

function UniToCodepage(i: integer): char;

//// Ikke komplet !!!!
var cp: integer;

  begin
////  cp:=GetCharSet;
    case (i) of
    32..127:
      UniToCodepage:=chr(i);
    128:
      UniToCodepage:='�';
    133:
      UniToCodepage:='�';
    135:
      UniToCodepage:='�';
    137:
      UniToCodepage:='�';
    139:
      UniToCodepage:='�';
    140:
      UniToCodepage:='�';
    141:
      UniToCodepage:='�';
    147:
      UniToCodepage:='�';
    149:
      UniToCodepage:='�';
    150:
      UniToCodepage:='�';
    151:
      UniToCodepage:='�';
    152:
      UniToCodepage:='�';
    157:
      UniToCodepage:='�';
    164:
      UniToCodepage:='�';
    165:
      UniToCodepage:='�';
    182:
      UniToCodepage:='�';
    183:
      UniToCodepage:='�';


    192:
      UniToCodepage:='�';

    193:
      UniToCodepage:='�';

    194:
      UniToCodepage:='�';
    195:
      UniToCodepage:='�';
    196:
      UniToCodepage:='�';

    197:
      UniToCodepage:='�';
    198:
      UniToCodepage:='�';
    199:
      UniToCodepage:='�';
    201:
      UniToCodepage:='�';

    202:
      UniToCodepage:='�';
    203:
      UniToCodepage:='�';
    204:
      UniToCodepage:='�';


    205:
      UniToCodepage:='�';


    206:
      UniToCodepage:='�';
    207:
      UniToCodepage:='�';
    208:
      UniToCodepage:='�';





    209:
      UniToCodepage:='�';


    210:
      UniToCodepage:='�';
    211:
      UniToCodepage:='�';
    212:
      UniToCodepage:='�';
    213:
      UniToCodepage:='�';
    214:
      UniToCodepage:='�';
    215:
      UniToCodepage:='�';
    216:
      UniToCodepage:='�';
    217:
      UniToCodepage:='�';
    218:
      UniToCodepage:='�';
    219:
      UniToCodepage:='�';
    220:
      UniToCodepage:='�';

    221:
      UniToCodepage:='�';
    222:
      UniToCodepage:='�';
    223:
      UniToCodepage:='�';
    224:
      UniToCodepage:='�';
    225:
      UniToCodepage:='�';


    226:
      UniToCodepage:='�';
    227:
      UniToCodepage:='�';
    228:
      UniToCodepage:='�';

    229:
      UniToCodepage:='�';
    230:
      UniToCodepage:='�';
    231:
      UniToCodepage:='�';
    232:
      UniToCodepage:='�';
    233:
      UniToCodepage:='�';
    234:
      UniToCodepage:='�';
    235:
      UniToCodepage:='�';


    236:
      UniToCodepage:='�';
    237:
      UniToCodepage:='�';
    238:
      UniToCodepage:='�';
    239:
      UniToCodepage:='�';
    240:
      UniToCodepage:='�';
    241:
      UniToCodepage:='�';
    242:
      UniToCodepage:='�';
    243:
      UniToCodepage:='�';
    244:
      UniToCodepage:='�';
    245:
      UniToCodepage:='�';
    246:
      UniToCodepage:='�';
    248:
      UniToCodepage:='�';
    249:
      UniToCodepage:='�';
    250:
      UniToCodepage:='�';
    251:
      UniToCodepage:='�';
    252:
      UniToCodepage:='�';
    253:
      UniToCodepage:='�';
    254:
      UniToCodepage:='�';
    255:
      UniToCodepage:='�';
    else
      begin
      if i<128 then
        UniToCodepage:=chr(i)
      else
        UniToCodepage:=chr(32);
      end;
    end
  end;
{$endif}

procedure SaveMidiData;

var
{$ifdef DelphiXe}
    F: File;
{$else}
    F: TextFile;
    i: integer;
{$endif}
    DataOut: integer;

  begin
  if FileName<>'' then
    begin
{$define PFILE}
{$ifdef PFILE}

{$ifdef FPC}
    AssignFile(F,Utf8ToAnsi(FileName+'.mid'));
{$else}
    AssignFile(F,(FileName+'.mid'));
{$endif}

//// Check detta!  (ifdef-erna)

{$ifdef DelphiXe}
    if FileExists(FileName+'.mid') then   //// Check filen kan slettes !!!!
      DeleteFile(FileName+'.mid');        //// Evt. s�t (2) p�.
    rewrite(F,1);
    BlockWrite(F,MidiData.MidiDataSelected,MidiData.MidiDataIndexMax);
  {$else}
    rewrite(F);
    for i:=1 to MidiData.MidiDataIndexMax do
      write(F,chr(MidiData.MidiDataSelected[i-1]));
  {$endif}
    CloseFile(F);
  {$else}
      DataOut:=FileOpen(FileName+'.mid',fmOpenWrite or fmShareDenyNone);
    FileWrite(Dataout,MidiData.MidiData,MidiData.MidiDataIndexMax);
    FileClose(Dataout);
  {$endif}
    end;
  end;



end.
