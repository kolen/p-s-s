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

(defonce app-state (atom {:categories categories}))

(defn hello-world []
  [:h1 (:text @app-state)])

(defn word [word]
  [:span.word {:style {:padding "10px"}} (:word word)])

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

(defn category [category category-id]
  [:div.category {:style {:border "1px solid #f00"}}
   category-id
   (for [[w-id w] (category :words)]
     ^{:key w} [word w])
   [word-input category category-id]])

(defn editor [categories]
  [:div.editor
   (for [[c-id c] categories] ^{:key c-id} [category c c-id])])

(defn app [] [editor (@app-state :categories)])

(r/render-component [app]
                    (. js/document (getElementById "app")))


(defn on-js-reload []
  ;; optionally touch your app-state to force rerendering depending on
  ;; your application
  ;; (swap! app-state update-in [:__figwheel_counter] inc)
)
