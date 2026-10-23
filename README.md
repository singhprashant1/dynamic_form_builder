# Dynamic Form Builder

Flutter app that renders menus, sub-menus and forms from JSON. Clean Architecture (domain / data / presentation) with a BLoC `Cubit`.

```sh
flutter pub get
flutter run
flutter test
```

## JSON

- `assets/data/workspaces.json` lists the workspaces (`id`, `title`, `icon`, `source`).
- `assets/data/configs/*.json` holds one menu tree per workspace: Sales, HR, Inventory, School.

```json
{
  "appTitle": "Sales & CRM",
  "menus": [
    {
      "id": "customer", "title": "Customers", "icon": "people",
      "subMenus": [
        {
          "id": "customer_add", "title": "Add Customer", "icon": "person_add",
          "form": {
            "title": "New Customer",
            "fields": [{ "key": "name", "type": "text", "label": "Full Name", "required": true }],
            "buttons": [{ "label": "Save", "action": "submit" }]
          }
        }
      ]
    }
  ]
}
```

- Field `type`: `text`, `email`, `number`, `phone`, `password` or `multiline`.
- Button `action`: `submit` (checks required fields), `reset` or `cancel`.

## Code

```text
lib/
├── main.dart                       wires repository → MenuCubit → MaterialApp
├── domain/                         entities + MenuRepository interface
├── data/                           JsonDataSource (reads asset) + MenuRepositoryImpl (JSON → entities)
└── presentation/
    ├── cubit/                      MenuCubit: loading / loaded / error + selected item
    ├── pages/                      HomePage: drawer menu, selected form in the body
    └── widgets/                    MenuDrawer, FormView, DynamicField, app_icons
```
