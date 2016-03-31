(ns pss.actions
  (:require-macros [cljs.core.async.macros :refer [go go-loop]])
  (:require [cljs.core.async :refer [chan]]
            [pss.data :refer [app-state]]))

(defonce pending-actions (chan))

(defn call [& args]
  (go (>! pending-actions args)))

(defmulti action (fn [ac & args] ac))

(defmethod action :add-word [])

(defmethod action :drag-start [_ word-id]
  (swap! app-state assoc-in [:words word-id :dragged] true))

(defmethod action :drag-end [_ word-id]
  (swap! app-state update-in [:words word-id] dissoc :dragged))

(defmethod action :drag-word-enter-category [_ category-id]
  (swap! app-state assoc-in [:categories category-id :insertion] true))

(defmethod action :drag-word-leave-category [_ category-id]
  (swap! app-state update-in [:categories category-id] dissoc :insertion))

(defmethod action :add-word [_ category-id word]
  (swap! app-state assoc-in [:words -1] {:word word :category-id category-id}))

(defmethod action :modify [_ entity id attr value]
  (swap! app-state assoc-in [entity id attr] value))

(defn start [] (go-loop []
                 (let [current-action (<! pending-actions)]
                   ;;(print "action:" current-action)
                   ;;(print "app-state" @app-state)
                   (apply action current-action)
                   ;;(print "app-state after" @app-state)
                   (recur))))
