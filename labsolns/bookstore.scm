(define-module (labsolns bookstore)
 
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system gnu)
  #:use-module (guix build-system guile)
  #:use-module (gnu packages guile)
  #:use-module (guix utils)
  #:use-module ((guix build utils) #:select (alist-replace))
  #:use-module (ice-9 match)
;;  #:use-module (ice-9 readline)
  #:use-module (guix gexp)
;;  #:use-module (dbi dbi)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module ((srfi srfi-1) #:select (alist-delete))
  #:use-module (gnu packages pkg-config)
  #:use-module (json)
  )

(define-public bookstore
             (let ((commit "75e26a7ee861ab4da004a7591b0c483c03efbed9")
        (revision "1"))
  (package
    (name "bookstore")
    (version (string-append "0.1." (string-take commit 7)))
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/mbcladwell/bookstore.git")
             (commit commit)))
              (file-name (git-file-name name version))
              (sha256
             (base32 "0n8nyisjsv2m4q2lpybvl266iihkh5bl0mr9xvcdpw225wzixkbk"))))
    (build-system guile-build-system)

  (arguments `(
	       #:modules
                ((ice-9 readline)	
          (ice-9 pretty-print))))
         

    
    (native-inputs
     `(("guile" ,guile-3.0)
       ))
      (propagated-inputs
    `(
      ("guile-json" ,guile-json-4)
    		))
       
    (home-page "https://notabug.org/cwebber/guile-squee")
    (synopsis "Book library compatible with Urbit")
    (description
     "A simple command line book library suitable for storing books in your Urbit pier.")
    (license license:lgpl3+))))


bookstore
