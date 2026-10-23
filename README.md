# Dynamic Form Builder

Flutter app whose menus, sub-menus and forms are rendered entirely from JSON.
Built with Clean Architecture, SOLID and BLoC.

## Run

```sh
flutter pub get
flutter run
flutter test
```

## Configs

| File | Purpose |
| --- | --- |
| `assets/data/workspaces.json` | List of workspaces shown in the switcher |
| `assets/data/configs/sales.json` | Sales & CRM (root: grid) |
| `assets/data/configs/hr.json` | HR Portal (root: list) |
| `assets/data/configs/inventory.json` | Inventory (root: grid, includes a failing mock API) |
| `assets/data/configs/school.json` | School Admin (root: tabs) |

To add a workspace, add a config file under `assets/data/configs/` and an entry in `workspaces.json`.

### Workspace entry

```json
{ "id": "hr", "title": "HR Portal", "description": "…", "icon": "groups", "color": "#00897B", "source": "assets/data/configs/hr.json" }
```

`color` seeds the app theme when that workspace is active.

### Config

```jsonc
{
  "appTitle": "HR Portal",
  "layout": "list",            // how top-level menus render
  "menus": [ /* menu items */ ]
}
```

### Menu item

| Key | Notes |
| --- | --- |
| `id`, `title` | required |
| `description` | subtitle |
| `icon` | Material icon name, see `lib/core/presentation/app_icons.dart` |
| `color` | `#RRGGBB` accent |
| `layout` | how **its sub-menus** render: `grid` \| `list` \| `tabs` \| `expandable` |
| `subMenus` | child items (any depth) |
| `form` | form to open when the item has no sub-menus |

In a `tabs` layout, a child with a form shows it inline in the tab; a child with sub-menus shows them in its own `layout`.

### Form, fields, buttons

```jsonc
{
  "title": "New Customer",
  "description": "Fields marked * are required.",
  "fields": [
    {
      "key": "phone", "type": "phone", "label": "Phone", "hint": "10 digits", "icon": "phone",
      "required": true, "minLength": 10, "maxLength": 10, "maxLines": 1, "initialValue": "",
      "pattern": "^[0-9]{10}$", "patternMessage": "Enter a valid 10 digit number"
    }
  ],
  "buttons": [
    { "label": "Reset", "action": "reset", "style": "outlined", "icon": "refresh" },
    {
      "label": "Save", "action": "submit", "style": "filled", "icon": "save",
      "api": {
        "endpoint": "/api/customers", "method": "POST",
        "successMessage": "Customer saved", "errorMessage": "Could not save",
        "mock": { "delayMs": 900, "fail": false }
      }
    }
  ]
}
```

- Field `type` can be `text`, `email`, `number`, `phone`, `password` or `multiline`.
- Button `action` can be `submit`, `reset` or `cancel`. A `submit` validates the fields, then calls `api`.
- Button `style` can be `filled`, `tonal`, `outlined` or `text`.
- `api` is served by `MockFormRepository`. To call a real backend, write an HTTP `FormRepository` and register it in `lib/core/di/injection.dart`; the `mock` block is then ignored.

## Architecture

```text
lib/
├── core/            di, errors, Result, UseCase, shared UI (theme, icons, status view)
└── features/
    ├── menu/          domain → data → presentation (MenuBloc, layouts, workspace switcher)
    └── dynamic_form/  domain → data → presentation (DynamicFormBloc, field builders, action bar)
```

- **New field type:** implement `FieldBuilder` and register it in `FieldBuilderRegistry`.
- **New validation rule:** implement `FieldValidator` and add it to `ValidateForm`.
- **Remote configs:** implement `MenuDataSource` and swap it in DI.
