(define-module (guile-oauth)
 #:use-module ((guix licenses) #:prefix license:)
 #:use-module (gnu packages autotools)
 #:use-module (gnu packages guile)
 #:use-module (gnu packages bash)
 #:use-module (gnu packages pkg-config)
 #:use-module (gnu packages texinfo)
 #:use-module (gnu packages linux)
 #:use-module (guix packages) 
  #:use-module (guix download)
  #:use-module (guix utils)
  #:use-module (gnu packages)
  #:use-module (gnu packages tls)
   #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix modules)
    #:use-module (guix derivations)
  #:use-module (guix store)
  #:use-module (guix git-download)
  #:use-module (guix hg-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix utils)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages tls)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  #:use-module (gnu packages guile-xyz)

  #:use-module (gnu packages)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages avahi)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages crypto)
  #:use-module (gnu packages databases)
  #:use-module (gnu packages disk)
  #:use-module (gnu packages gettext)
  #:use-module (gnu packages gl)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages gperf)
  #:use-module (gnu packages gstreamer)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages hurd)
  #:use-module (gnu packages image)
  #:use-module (gnu packages imagemagick)
  #:use-module (gnu packages libffi)
  #:use-module (gnu packages libunistring)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages man)
  #:use-module (gnu packages maths)
  #:use-module (gnu packages mes)
  #:use-module (gnu packages multiprecision)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages noweb)
  #:use-module (gnu packages nss)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages password-utils)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages python)
  #:use-module (gnu packages readline)
  #:use-module (gnu packages tex)
  #:use-module (gnu packages texinfo)
  #:use-module (gnu packages tls)
  #:use-module (gnu packages version-control)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix modules)
  #:use-module (guix monads)
   #:use-module (guix i18n)
  #:use-module (guix records)
  #:use-module (guix search-paths)
   #:use-module (guix derivations)
  #:use-module (guix store)
  #:use-module (guix git-download)
  #:use-module (guix hg-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix utils)
  #:use-module (ice-9 pretty-print)
  #:autoload   (srfi srfi-98) (get-environment-variables)
  #:use-module (guix build utils)
  #:use-module (guix gexp)
  #:use-module (ice-9 match)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system glib-or-gtk)
  #:use-module (guix build-system guile)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages aspell)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages gawk)
  #:use-module (gnu packages sdl)
  #:use-module (gnu packages search)
  #:use-module (gnu packages serialization)
  #:use-module (gnu packages slang)
  #:use-module (gnu packages sqlite)
  #:use-module (gnu packages swig)
  #:use-module (gnu packages webkit)
  #:use-module (gnu packages xdisorg)
  #:use-module (gnu packages xorg)
  
  )

(define-public guile-oauth
(package
  (name "guile-oauth")
  (version "1.1.0") 
   (source (origin
            (method url-fetch)
             (uri https://github.com/mbcladwell/guile-oauth/releases/download/1.1.0/guile-oauth-1.1.0.tar.gz)          
            (sha256
             (base32
              "1ly1nvwyk7n0i8f2rpx78lx4jvfk5z9g4ng52wb1q56p96w21qz7"))))             
  (properties `((upstream-name . "guile-oauth")))
  (build-system gnu-build-system)
   (inputs
    `(("guile" ,guile-3.0)))
   (propagated-inputs
    `(
      ("guile-json" ,guile-json-3)
      ("guile-gcrypt" ,guile-gcrypt)
      ("gnutls" ,gnutls)
  		))
    (native-inputs
     `(("bash"       ,bash)         ;for the `source' builtin
       ("pkgconfig"  ,pkg-config)
       ("autoconf" ,autoconf)
       ("automake" ,automake)
       ("texinfo" ,texinfo)
       ("util-linux" ,util-linux))) ;for the `script' command
  (home-page "https://github.com/aconchillo/guile-oauth")
  (synopsis "guile-oauth is an OAuth client module for Guile.")
  (description
    "guile-oauth is an OAuth client module for Guile.")
  (license license:gpl3)))
  

