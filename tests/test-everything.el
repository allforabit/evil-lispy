
(describe "with-test-buffer macro"
  (it "inserts buffer contents and returns them"
    (expect (with-test-buffer "hello world|")
            :to-equal "hello world|"))

  (it "returns multiple lines as a list"
    (expect (with-test-buffer "hello\n|world")
            :to-equal (list "hello"
                            "|world")))

  (it "allows calling code in the given buffer"
    (expect (with-test-buffer "hello\n|world"
              ;; move cursor to end of line
              (evil-append-line 1))
            :to-equal (list "hello"
                            "world|"))))

(describe "when inside an expression, enter insert mode at start or end"
  (it "allows inserting at the start"
    (expect (with-test-buffer "(foo-foo-|foo)"
              (evil-lispy-enter-insert-state-left))
            :to-equal "(| foo-foo-foo)"))

  (it "allows inserting at the end"
    (expect (with-test-buffer "(foo-foo-|foo)"
              (evil-lispy-enter-insert-state-right))
            :to-equal "(foo-foo-foo |)")))

(describe "entering lispy marked state"
  (it "selects a symbol"
    (expect (with-test-buffer "hello the|re, world"
              (evil-lispy-enter-marked-state))
            :to-equal "hello ~there|, world"))

  (it "selects an expression"
    (expect (with-test-buffer "(hello the|re world)"
              (evil-lispy-enter-marked-state))
            :to-equal "(hello ~there| world)"))

  (it "allows entering from evil-visual-state"
    (expect (with-test-buffer "some words |in the buffer"
              ;; select the current word
              (evil-visual-state)
              (evil-inner-word)
              (evil-lispy-enter-visual-state)

              (insert (prin1-to-string lispy-mode)))
            ;; oh dear, this is one of the worst hacks ever.
            ;; lispy-mode should be t at this point, so inserting it will alter
            ;; the buffer contents.
            :to-equal "some words ~int| the buffer")))

(describe "enter lispy-mode at edges of the current expression"
  (it "before an expression"
    (expect (with-test-buffer "(an expression| here)"
              (evil-lispy-enter-state-left))
            :to-equal "|(an expression here)"))

  (it "after an expression"
    (expect (with-test-buffer "(an expression| here)"
              (evil-lispy-enter-state-right))
            :to-equal "(an expression here)|")))