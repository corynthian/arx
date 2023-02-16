(ql:quickload :ningle)
(ql:quickload :clack)
(ql:quickload :lack)
(ql:quickload :spinneret)

(defpackage #:server
  (:use #:cl #:ningle #:clack #:lack #:spinneret))

(in-package #:server)

(defvar *app* (make-instance 'ningle:app))

(defun index ()
  (with-html-string (:doctype)
    (:html
     (:head
      (:title "ARX")
      (:link :rel "stylesheet" :href "/static/css_init.css")
      (:script :type "text/javascript" :src "/static/index.global.js")
      (:script :type "text/javascript" :src "/static/output.js"))
     (:body
      (:div :id "elmMain")
      (:script :type "text/javascript" :src "/static/elm_init.js")))))

(setf (ningle:route *app* "/")
      #'(lambda (params) (index)))
(setf (ningle:route *app* "/account")
      #'(lambda (params) (index)))
(setf (ningle:route *app* "/subsidialis")
      #'(lambda (params) (index)))
(setf (ningle:route *app* "/subsidialis/add_coins")
      #'(lambda (params) (index)))
(setf (ningle:route *app* "/subsidialis/add_liquidity")
      #'(lambda (params) (index)))

(setf *app*
      (lack:builder
       (:static :path "/static/" :root #P"./static/")
       *app*))

(clack:clackup *app* :server :woo)
