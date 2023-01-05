# Dependencies

- [qb-target](https://github.com/BerkieBb/qb-target)
- [keep-menu](https://github.com/swkeep/keep-menu)
- [polyzone](https://github.com/qbcore-framework/PolyZone)

# Preview 
- [video](https://www.youtube.com/watch?v=LOjn07qMLmc)

## Installation

- Install all dependencies
- Drag and drop resource in your resources list 
- Make sure script is loaded after all dependencies

- A new Item need to be added with it's image :
```lua
	-- crafting-blueprint
	    ["blueprint_document"] = {
        ["name"] = "blueprint_document",
        ["label"] = "Blueprint",
        ["weight"] = 100,
        ["type"] = "item",
        ["image"] = "blueprint_document.png",
        ["unique"] = true,
        ["useable"] = false,
        ["shouldClose"] = false,
        ["combinable"] = nil,
        ["description"] = "A blueprint document that help you craft."
    },
```

- in qb-inventory\js\app.js find FormatItemInfo() and add this code at end of the function
```js
if (itemData.name == "blueprint_document") { // Blueprint for crafting
    $(".item-info-title").html("<p>" + itemData.label + "</p>");
    $(".item-info-description").html(
        "<p><span>" + itemData.description + "</span></p>" +
        "<p><strong>Blueprint :</strong> " + itemData.info.blueprint_label + "</p>"
    );
}
```

- Blueprints can be given by using this command `/giveblueprint name`
