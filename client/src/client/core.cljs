(ns ^:figwheel-always client.core
  (:require [reagent.core :as r :refer [atom]]))

(enable-console-print!)

;; define your app data so that it doesn't get over-written on reload

(defn sample-words [words]
  (into {} (for [word words] [word {:word word}])))

(defonce categories
  {1 {:name ""
      :words (sample-words ["lolka" "lalka" "rorka"])}
   2 {:name "zazez"
      :words (sample-words ["zazka" "glinka" "rorka"])}})

(defonce app-state (atom {:categories categories
                          :insertion nil}))

; (swap! app-state assoc-in [:categories 1 :insertion] true)

(defonce drag-state (atom {}))

(print @drag-state)

(defn word-drag-enter [category-id e]
  (print "enter" category-id)
  (swap! drag-state update-in [category-id] inc)
  (swap! app-state assoc-in [:categories category-id :insertion] true))

(defn word-drag-leave [category-id e]
  (print "leave" category-id)
  (swap! drag-state update-in [category-id] dec)
  (if (= 0 (@drag-state category-id))
    (swap! app-state update-in [:categories category-id] dissoc :insertion)))

(defn word [word]
  [:div.word {:style {:margin "10px"}
              :draggable true
              :on-drag #()}
   (:word word)])

(defn add-word [category-id word]
  (swap! app-state assoc-in [:categories category-id :words word] {:word word}))

(defn word-input []
  (let [val (r/atom "")]
    (fn [category category-id]
      [:input {:type :text
               :on-change #(reset! val (-> % .-target .-value))
               :on-key-down (fn [key] (case (.-which key)
                                        13 (add-word category-id @val)
                                        nil))}])))

(defn insertion-point [enabled?]
  (if enabled?
    [:div.insertion {:style {:background "#f00" :height "40px"}}]
    nil))

(defn category [category category-id]
  [:div.category {:style {:border "1px solid #f00" :width "200px" :background "#fff" :float :left}
                  :on-drag-enter (partial word-drag-enter category-id)
                  :on-drag-leave (partial word-drag-leave category-id)}
   category-id
   (for [[w-id w] (category :words)]
      ^{:key w-id} [word w])
   [insertion-point (category :insertion)]
   [word-input category category-id]])

(defn editor [app-state]
  [:div.editor
   (for [[c-id c] (app-state :categories)]
     ^{:key c-id} [category c c-id (app-state :insertion)])])

(defn app [] [editor @app-state])

(r/render-component [app]
                    (. js/document (getElementById "app")))


(defn on-js-reload []
  ;; optionally touch your app-state to force rerendering depending on
  ;; your application
  ;; (swap! app-state update-in [:__figwheel_counter] inc)
)
