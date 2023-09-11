(use-modules
  (guix packages)
  ((guix licenses) #:prefix license:)
  (guix download)
  (guix build-system gnu)
  (gnu packages)
  (gnu packages autotools)
  (gnu packages guile)
  (gnu packages guile-xyz)
  (gnu packages pkg-config)
  (gnu packages texinfo)
  (gnutls))

(define-public conmanv4
             (let ((commit "2e3d2eb5e9412b14f3508e2a9f00615c95eb676b")
        (revision "1"))
  (package
    (name "conmanv4")
    (version (string-append "0.1." (string-take commit 7)))
    (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/mbcladwell/conmanv4.git")
             (commit commit)))
              (file-name (git-file-name name version))
              (sha256
             (base32 "0l264qscqwj2fkqz50mq4vnkcny18bnlwp4gvrvg8ykc81kw3d90"))))
    (build-system guile-build-system)

  (arguments `(#:tests? #false ; there are none
	       #:phases (modify-phases %standard-phases
       		       (add-after 'unpack 'patch-prefix
			       (lambda* (#:key inputs outputs #:allow-other-keys)
					(substitute* "conmanv4/env.scm"
						(("abcdefgh")
						(assoc-ref outputs "out" )) )
					#t))
		       (add-before 'install 'make-dir
			       (lambda* (#:key outputs #:allow-other-keys)
				    (let* ((out  (assoc-ref outputs "out"))
					   (bin-dir (string-append out "/bin"))
					   (dummy (mkdir-p bin-dir))
					   )            				       
				       (copy-recursively "./bin" bin-dir)
				       #t)))
		       (add-before 'install 'make-dir
			       (lambda* (#:key outputs #:allow-other-keys)
				    (let* ((out  (assoc-ref outputs "out"))
					   (scripts-dir (string-append out "/scripts"))
					   (dummy (mkdir-p scripts-dir))
					   )            				       
				       (copy-recursively "./scripts" scripts-dir)
				       #t))))))
  (native-inputs
   `(
      ("texinfo" ,texinfo)))
  (inputs `(("guile" ,guile-3.0)))
  (propagated-inputs `())
  (synopsis "")
  (description "")
  (home-page "www.labsolns.com")
  (license license:gpl3+))

