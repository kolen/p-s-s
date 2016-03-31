(ns pss.ui
  (:require [pss.data :refer [app-state]]
            [pss.actions :as act]
            [reagent.core :as r]))

(enable-console-print!)

(defonce drag-state (atom {}))

(defn word-drag-enter [category-id e]
  (swap! drag-state update-in [category-id] inc)
  (act/call :drag-word-enter-category category-id)
  (.preventDefault e))

(defn word-drag-leave [category-id e]
  (swap! drag-state update-in [category-id] dec)
  (if (= 0 (@drag-state category-id))
    (act/call :drag-word-leave-category category-id)))

(defn word-drag-start [word-id e]
  (act/call :drag-start word-id))

(defn word-drag-end [word-id e]
  (act/call :drag-end word-id))

(defn word [word word-id]
  [:div.word {:draggable true
              :on-drag-start (partial word-drag-start word-id)
              :on-drag-end (partial word-drag-end word-id)
              :class (if (:dragged word) "dragged" "")}
   (:word word)])

(defn word-input []
  (let [val (r/atom "")]
    (fn [category category-id]
      [:input {:type :text
               :value @val
               :on-change #(reset! val (-> % .-target .-value))
               :on-key-down (fn [key]
                              (case (.-which key)
                                13 (do (act/call :add-word category-id @val)
                                       (reset! val ""))
                                nil))}])))

(defn insertion-point [enabled?]
  (if enabled?
    [:div.insertion.insertion-word]
    nil))

(defn category [category category-id words]
  [:div.category {:on-drag-enter (partial word-drag-enter category-id)
                  :on-drag-leave (partial word-drag-leave category-id)
                  :on-drag-over  #(.preventDefault %)
                  :on-drop       #(print "drop" %)}
   [:div.name (category :name)]

   (for [[w-id w] words :when (= category-id (w :category-id))]
     ^{:key w-id} [word w w-id])
   [insertion-point (category :insertion)]
   [word-input category category-id]])

(defn editor [app-state]
  [:div.editor
   (for [[c-id c] (app-state :categories)]
     ^{:key c-id} [category c c-id (app-state :words)])])

(defn app [] [editor @app-state])

(r/render-component [app]
                    (. js/document (getElementById "app")))


(act/start)

(defn on-js-reload []
  ;; optionally touch your app-state to force rerendering depending on
  ;; your application
  ;; (swap! app-state update-in [:__figwheel_counter] inc)
)
