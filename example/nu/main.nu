;;
;; main.nu
;;
;; Example of an application using NuSMTPMessage.
;; NuSMTPMessage is a simple class wrapper for 
;; Ian Baird's SKPSMTPMessage classes.
;;
;; Copyright (c) 2009 Jeff Buck


(load "Nu:nu")
(load "Nu:cocoa")
(load "Nu:menu")

(load "NuSMTP")

;; dynamic creation of buttons and textfields lifted
;; from Nu's RandomApp example...
(function standard-cocoa-button (frame)
     (((NSButton alloc) initWithFrame:frame)
      set: (bezelStyle:NSRoundedBezelStyle)))

(function standard-cocoa-textfield (frame)
     (((NSTextField alloc) initWithFrame:frame)
      set: (bezeled:0 editable:0 alignment:NSRightTextAlignment drawsBackground:0)))

(function standard-cocoa-editfield (frame)
     (((NSTextField alloc) initWithFrame:frame)
      set: (bezeled:1 editable:1 alignment:NSLeftTextAlignment drawsBackground:0)))

(function secure-cocoa-editfield (frame)
     (set field (((NSSecureTextField alloc) initWithFrame:frame)
                 set: (bezeled:1 editable:1 alignment:NSLeftTextAlignment drawsBackground:0))))

(macro-1 dec! (n d)
     `(set ,n (- ,n ,d)))

;; Some magic layout dimensions
(set $labelwidth 120)
(set $labelheight 20)

(set $editwidth 220)
(set $editheight 20)

;; Create a text label on the left and an edit field on the right.
;; It's a macro because we want to bind the ivars.
(macro-1 form-field (view x y field-type label default label-var edit-var)
     `(progn
            ;; dynamically calculate where the edit box should start
            (set __xedit (+ ,x $labelwidth 10))
            (let (t (standard-cocoa-textfield (list ,x ,y $labelwidth $labelheight)))
                 (t setStringValue: ,label)
                 (,view addSubview:t)
                 (set ,label-var t))
            (let (t (,field-type (list __xedit ,y $editwidth $editheight)))
                 (t setStringValue: ,default)
                 (,view addSubview:t)
                 (set ,edit-var t))))

(class SMTPTestAppWindowController is NSObject
     (ivars)
     
     (- (id) init is
        (super init)
        (let (w ((NSWindow alloc)
                 initWithContentRect: '(300 200 400 280)
                 styleMask: (+ NSTitledWindowMask NSClosableWindowMask NSMiniaturizableWindowMask)
                 backing: NSBackingStoreBuffered
                 defer: 0))
             (w set: (title:"SMTP Test App"))
             (let (v ((NSView alloc) initWithFrame:(w frame)))
                  (set x 20)
                  (set y 250)
                  (set ydelta 25)
                  
                  (form-field v x y standard-cocoa-editfield "From Email:" "me@here.com" @fromEmailLabel @fromEmail)
                  (dec! y ydelta)
                  (form-field v x y standard-cocoa-editfield "To Email:" "you@there.com" @toEmailLabel @toEmail)
                  (dec! y ydelta)
                  (form-field v x y standard-cocoa-editfield "Relay Host:" "smtp.gmail.com" @relayHostLabel @relayHost)
                  (dec! y ydelta)
                  (form-field v x y standard-cocoa-editfield "User:" "someone@gmail.com" @userLabel @user)
                  (dec! y ydelta)
                  (form-field v x y secure-cocoa-editfield "Password:" "" @passwordLabel @password)
                  (dec! y ydelta)
                  (dec! y ydelta)
                  (form-field v x y standard-cocoa-editfield "Subject:" "Email from NuSMTP" @subjectLabel @subject)
                  (dec! y ydelta)
                  (form-field v x y standard-cocoa-editfield "Text:" "This is a test." @messageTextLabel @messageText)
                  
                  (let (b (standard-cocoa-button '(150 20 220 25)))
                       (b set: (title: "Send Message" target: self action:"sendMessage:"))
                       (v addSubview:b)
                       (set @sendButton b))
                  
                  (w setContentView:v))
             (w center)
             (set @window w)
             (w makeKeyAndOrderFront:self))
        self)
     
     (- (void) sendMessage: (id) sender is
        (set msg ((NuSMTPMessage alloc)
                  initWithFromEmail:(@fromEmail stringValue)
                  toEmail:(@toEmail stringValue)
                  relayHost:(@relayHost stringValue)
                  login:(@user stringValue)
                  password:(@password stringValue)
                  subject:(@subject stringValue)))
        (msg addTextPart:(@messageText stringValue))

		;; Also send a sample image as a demonstration of an attachment.
        (set vcfPath ((NSBundle mainBundle) pathForResource:"rule30" ofType:"jpg"))
        (set vcfData (NSData dataWithContentsOfFile:vcfPath))
		(msg addDataPart:vcfData mimeType:"image/jpeg" name:"rule30.jpg")
		
        (msg send))
     
     (- (void) generate: (id) sender is
        (@textField setIntValue:(NuMath random))))



(class ApplicationDelegate is NSObject
     (- (void) applicationDidFinishLaunching: (id) sender is
        (build-menu default-application-menu "SMTPTestApp")
        (set $smtp ((SMTPTestAppWindowController alloc) init)))
     
     ;; Close the application when the window is closed
     (- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (id) app is
        YES))

;; install the delegate and keep a reference to it since the application won't retain it.
((NSApplication sharedApplication) setDelegate:(set delegate ((ApplicationDelegate alloc) init)))

;; this makes the application window take focus when we've started it from the terminal
((NSApplication sharedApplication) activateIgnoringOtherApps:YES)

;; run the main Cocoa event loop
(NSApplicationMain 0 nil)
