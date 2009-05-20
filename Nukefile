;;
;; Nukefile for NuSMTP
;;
;; Commands:
;;	nuke          - builds NuSMTP as a framework
;;	nuke install  - installs NuSMTP in /Library/Frameworks
;;	nuke clean    - removes build artifacts
;;	nuke clobber  - removes build artifacts and NuSMTP.framework
;;


;; source files
(set @m_files     (filelist "^objc/.*.m$"))

;; framework description
(set @framework "NuSMTP")
(set @framework_identifier   "nu.programming.smtp")
(set @framework_creator_code "????")

(set @cflags "-g -fobjc-gc -std=gnu99 -I Source")

(set @ldflags "-framework Foundation -framework CoreServices")

(compilation-tasks)
(framework-tasks)

(task "clobber" => "clean" is
      (SH "rm -rf #{@framework_dir}")) ;; @framework_dir is defined by the nuke framework-tasks macro

(task "default" => "framework")

(task "install" => "framework" is
      (SH "sudo rm -rf /Library/Frameworks/#{@framework}.framework")
      (SH "ditto #{@framework}.framework /Library/Frameworks/#{@framework}.framework"))

