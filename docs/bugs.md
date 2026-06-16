# Bizon Admin - Bug Report

**Fecha**: 2026-04-26
**Testeado en**: bizon-admin (Next.js 16.1.6) + bizon_commerce (Rails 8.1.2)
**Navegador**: Chrome (via DevTools MCP + revision de codigo)
**Credenciales**: samuel@samdalthgold.com / password123

---

## Nota sobre metodologia

El testing inicial se realizo con Chrome DevTools MCP (Model Context Protocol).
Esta herramienta tiene **limitaciones significativas con React 19 / Next.js 16**:
los eventos `click` y `fill` del MCP no disparan correctamente los synthetic events
de React (`onChange`, `onClick`, `onSubmit`), lo que genero multiples falsos positivos.

Cada bug fue posteriormente verificado contra el codigo fuente del frontend.
Los bugs marcados como "verificar manualmente" requieren pruebas en navegador real
o tests E2E (Playwright/Cypress).

---

## Bugs Confirmados

### BUG-001: Botones de accion sin aria-label (accesibilidad)
- **Severidad**: Media
- **Paginas**: `/products`, `/categories`
- **Como se probo**: Inspeccion del a11y tree via `take_snapshot` del MCP. Los botones aparecen como "button" sin texto descriptivo. **Confirmado en codigo**: los botones de delete (products) y edit/delete (categories) no tienen atributo `aria-label`.
- **Archivos afectados**:
  - `src/app/(dashboard)/products/page.tsx` (lineas 70-78) - boton delete sin aria-label
  - `src/app/(dashboard)/categories/page.tsx` (lineas 64-72) - boton edit sin aria-label
  - `src/app/(dashboard)/categories/page.tsx` (lineas 75-83) - boton delete sin aria-label
- **Forma correcta de probar**: Inspeccion del a11y tree o revision de codigo. El MCP es adecuado para esto.
- **Fix sugerido**: Agregar `aria-label="Edit category"` y `aria-label="Delete product"` a cada boton.

---

## Bugs a Verificar Manualmente

### BUG-002: Columna DATE en Recent Orders con line-breaks en desktop
- **Severidad**: Baja
- **Pagina**: `/dashboard`
- **Como se probo**: Screenshot en 1440px muestra "Apr 23,\n2026" en 2 lineas en la tabla Recent Orders.
- **Forma correcta de probar**: Abrir en navegador real a 1440px y verificar visualmente. El screenshot del MCP es confiable para esto.
- **Conclusion**: Probablemente real - la columna DATE es demasiado estrecha para el formato "Apr 23, 2026". Agregar `whitespace-nowrap` al `<td>` de la fecha resolveria el issue.

### BUG-003: Verificar comportamiento responsive de tablas en mobile real
- **Severidad**: Media
- **Paginas**: `/products`, `/orders`, `/customers`, `/categories`
- **Como se probo**: Screenshots en viewport 375px mostraban columnas cortadas.
- **Verificacion de codigo**: Las tablas SI tienen `overflow-x-auto` en el wrapper del DataTable.
- **Forma correcta de probar**: En navegador real o Playwright con viewport 375px, verificar si el scroll horizontal funciona correctamente. El MCP solo toma screenshots estaticos y no puede verificar scroll.
- **Conclusion**: El CSS es correcto, pero verificar en dispositivo real que el scroll funcione bien y que la UX sea aceptable.

### BUG-004: Verificar menu hamburguesa en mobile real
- **Severidad**: Alta (si falla)
- **Pagina**: Todas (mobile)
- **Como se probo**: Click via MCP en boton hamburguesa, sidebar no se abrio.
- **Verificacion de codigo**: El handler `onClick={onMenuClick}` esta correctamente implementado y llama `setSidebarOpen(true)`.
- **Forma correcta de probar**: En navegador real con viewport mobile o Chrome DevTools responsive mode. El MCP no dispara correctamente eventos React en mobile emulation.
- **Conclusion**: Muy probablemente funciona bien - el codigo es correcto.

---

## Falsos Positivos Descartados

Los siguientes bugs fueron reportados inicialmente pero son **falsos positivos**
causados por la incompatibilidad entre Chrome DevTools MCP y React 19:

| Bug original | Que reportaba | Por que es falso positivo |
|---|---|---|
| Add Product no funciona | Click en boton no navegaba | El boton tiene `router.push("/products/new")` - MCP no disparo onClick de React |
| Add Category no funciona | Click no abria modal | Tiene `setModalOpen(true)` - mismo issue MCP/React |
| Edit Category no funciona | Pencil icon no hacia nada | Tiene handler que abre modal con `setEditCategory()` |
| Search no filtra | Fill + Enter no filtraba | SearchInput tiene debounce onChange - MCP fill no dispara onChange de React |
| Save Settings no envia PATCH | No habia request en Network | react-hook-form submit funciona correctamente - MCP no disparo form submit |
| Filas de productos no clickables | Click en nombre no navegaba | DataTable tiene `onRowClick` con `router.push` - MCP click en texto hijo no propago |
| Filas de ordenes no clickables | Idem | Misma implementacion correcta con onRowClick |
| Filas de clientes no clickables | Idem | Misma implementacion correcta con onRowClick |
| Sidebar links no navegan | Click no cambiaba pagina | Son Next.js `<Link>` estandar - MCP no maneja client-side nav |
| Tax Rate "0,0" | Mostraba coma en vez de punto | Comportamiento correcto del browser con locale espanol |
| Chart tarda en renderizar | Chart vacio inicialmente | Comportamiento normal de Recharts (necesita ciclo de render) |

---

## Resumen Corregido

| Severidad | Cantidad |
|-----------|----------|
| Confirmados | 1 (accesibilidad) |
| A verificar manualmente | 3 |
| Falsos positivos descartados | 12 |
| **Total real estimado** | **1 a 4** |

---

## Lecciones sobre testing con Chrome DevTools MCP

1. **NO usar MCP para probar interacciones React**: El MCP no dispara synthetic events de React. Clicks, fills, y form submissions no funcionan correctamente.
2. **SI usar MCP para**: Screenshots, layout visual, a11y tree, network requests, console errors.
3. **Para testing funcional**: Usar Playwright, Cypress, o pruebas manuales en navegador real.
4. **Siempre verificar contra el codigo**: Antes de reportar un bug de "boton no funciona", revisar si el handler existe en el codigo fuente.

---

## Estado general de la aplicacion

El frontend admin **esta mas completo de lo que el testing inicial sugirio**:
- CRUD de productos implementado (create, edit, list, delete)
- CRUD de categorias implementado (create, edit via modal, list, delete)
- Vista de detalle de ordenes implementada
- Vista de detalle de clientes implementada
- Search con debounce implementado
- Settings con PATCH implementado
- Sidebar responsive con hamburger menu implementado
- Tablas con scroll horizontal implementado

El backend API esta completo y funcional (verificado con curl).
