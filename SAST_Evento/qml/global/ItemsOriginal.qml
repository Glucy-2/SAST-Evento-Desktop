pragma Singleton

import QtQuick
import FluentUI

Loader {
    id: loader

    function getInProgressData() {
        var arr = []
        for (var i = 0; i < loader.item.children.length; i++) {
            var item = loader.item.children[i]
            if (item instanceof FluPaneItem && item.inProgress) {
                arr.push(item)
            }
            if (item instanceof FluPaneItemExpander) {
                for (var j = 0; j < item.children.length; j++) {
                    var itemChild = item.children[j]
                    if (itemChild instanceof FluPaneItem
                            && itemChild.inProgress) {
                        arr.push(itemChild)
                    }
                }
            }
        }
        arr.sort(function (o1, o2) {
            return o2.order - o1.order
        })
        return arr
    }

    function getRecentlyUpdatedData() {
        var arr = []
        var items = loader.item.navigationView.getItems()
        for (var i = 0; i < items.length; i++) {
            var item = items[i]
            if (item instanceof FluPaneItem && item.recentlyUpdated) {
                arr.push(item)
            }
        }
        return arr
    }

    function getSearchData() {
        var arr = []
        var items = loader.item.navigationView.getItems()
        for (var i = 0; i < items.length; i++) {
            var item = items[i]
            if (item instanceof FluPaneItem) {
                if (item.parent instanceof FluPaneItemExpander) {
                    arr.push({
                                 "title": `${item.parent.title} -> ${item.title}`,
                                 "key": item.key
                             })
                } else
                    arr.push({
                                 "title": item.title,
                                 "key": item.key
                             })
            }
        }
        return arr
    }

    function startPageByItem(data) {
        loader.item.navigationView.startPageByItem(data)
    }
}
