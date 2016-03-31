(ns pss.data
  (:require [reagent.core :refer [atom]]))

(defonce categories
  {1 {:name ""}
   2 {:name "шприцы"}})

(defonce words
  {1 {:word "лолка" :category-id 1}
   2 {:word "верёвка" :category-id 1}
   3 {:word "жмур" :category-id 1}
   4 {:word "барабухайка" :category-id 2}
   5 {:word "словесный понос" :category-id 2}})

(defonce app-state (atom {:categories categories
                          :words words
                          :insertion nil
                          :drag {:dragged-word nil}}))
