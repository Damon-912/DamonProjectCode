---
name: fastadmin-table-optimization
description: Optimizes FastAdmin table layouts with responsive breakpoints, dynamic column freezing, and proper height/width calculations. Use this skill when working on FastAdmin/ThinkPHP table views that have layout issues, column misalignment, or need responsive design improvements.
---

# FastAdmin Table Optimization

## Overview

Provides comprehensive guidance for optimizing FastAdmin Bootstrap Table layouts with responsive design, dynamic column freezing, and proper dimension calculations. Addresses common issues like column misalignment, fixed column errors, and poor mobile/tablet responsiveness.

## When to Use This Skill

Use this skill when:
- FastAdmin table lists have column alignment issues, especially with fixed columns
- Tables appear misaligned after search, pagination, or window resize
- Fixed columns (checkbox, name, phone, action columns) shift or overlap
- Tables need responsive design improvements for mobile/tablet devices
- Table height calculations cause scrolling issues or cutoff content
- Layout breaks after search form expansion/collapse
- Table height disappears or becomes too small when search form expands
- 14-inch laptops show insufficient table height

## Core Guidelines

### 1. Use Bootstrap Standard Breakpoints

Always use Bootstrap's standard responsive breakpoints for consistency:

```javascript
const BREAKPOINT_SM = 576;   // Mobile portrait: < 576px
const BREAKPOINT_MD = 768;   // Mobile landscape/small tablet: 576px ~ 767px
const BREAKPOINT_LG = 992;   // Tablet: 768px ~ 991px
const BREAKPOINT_XL = 1200;  // Desktop: 992px ~ 1199px
const BREAKPOINT_XXL = 1400; // Large desktop: ≥ 1200px
```

**Why not 769px?**
- 769px is non-standard and creates edge case issues for devices at exactly 768px (iPad Mini)
- Bootstrap uses 768px as the md breakpoint
- Project consistency: Many existing JS files use 768px, mixing values causes bugs

### 2. Dynamic Fixed Column Configuration

Fixed columns must be responsive to avoid content挤压 on smaller screens:

```javascript
function getFixedColumnsConfig(bodyW) {
    if (bodyW < BREAKPOINT_SM) {
        return {
            fixedColumns: false,
            fixedNumber: 0,
            fixedRightNumber: 0,
            showColumns: false,
            showExport: false,
            fixedHeight: false
        };
    } else if (bodyW < BREAKPOINT_MD) {
        return {
            fixedColumns: true,
            fixedNumber: 2,        // checkbox + name
            fixedRightNumber: 0,
            showColumns: false,
            showExport: false,
            fixedHeight: false
        };
    } else if (bodyW < BREAKPOINT_LG) {
        return {
            fixedColumns: true,
            fixedNumber: 3,        // checkbox + id + name + phone
            fixedRightNumber: 0,
            showColumns: true,
            showExport: true,
            fixedHeight: true
        };
    } else if (bodyW < BREAKPOINT_XL) {
        return {
            fixedColumns: true,
            fixedNumber: 4,        // checkbox + id + name + phone
            fixedRightNumber: 1,     // action column
            showColumns: true,
            showExport: true,
            fixedHeight: true
        };
    } else {
        return {
            fixedColumns: true,
            fixedNumber: 5,        // checkbox + id + name + phone + department
            fixedRightNumber: 1,     // action column
            showColumns: true,
            showExport: true,
            fixedHeight: true
        };
    }
}
```

### 3. Precise Height Calculation

Use `outerHeight(true)` to capture full element dimensions including margins.

**Critical**: Do NOT include search form height in the calculation. The search form is expandable and should not affect table height - when expanded, the table should naturally scroll.

```javascript
function getTableHeight() {
    var bodyH = $(window).height();
    var h_ribbon = $('#ribbon').outerHeight(true) || 0;
    var h_panelHeading = $('.panel-heading').outerHeight(true) || 0;
    var h_toolbar = $('.fixed-table-toolbar').outerHeight(true) || 0;
    // Search form height NOT included - it's expandable and should not affect table height
    var h_searchForm = 0;
    var h_pagination = $('.fixed-table-pagination').outerHeight(true) || 40;

    // Bottom margin and padding reserve
    var margin = 0;

    var calculatedHeight = bodyH - h_ribbon - h_panelHeading - h_toolbar - h_searchForm - h_pagination - margin;

    // Set minimum height to ensure at least 10 rows of data (approximately 400px)
    var minHeight = 400;

    return Math.max(calculatedHeight, minHeight);
}
```

**Why exclude search form height?**
- Search form is expandable/collapsible
- Including it causes table to shrink too much when form is expanded
- Table should maintain usable height regardless of search form state
- Minimum height (400px) ensures data is always visible on 14-inch laptops

**Expected behavior**:
- ✅ Search conditions expand → table maintains reasonable height
- ✅ Bottom has no extra reserved space (margin = 0)
- ✅ Minimum height guarantees 400px (approx 10 rows of data)
- ✅ At least 10 rows of data visible
- ✅ Small screen devices display normally
- ✅ Auto-adjusts when search form expands/collapses

### 4. Accurate Width Calculation

Account for panel padding and container widths:

```javascript
function getTableWidth() {
    var bodyW = $(window).width();
    var panelPadding = 30; // Panel left/right padding
    return bodyW - panelPadding;
}
```

### 5. Unified Table Reset with Debounce

Combine resize, load-success, and search toggle events into a single reset function with 200ms debounce:

```javascript
var resizeTimer;
function resetTableView() {
    clearTimeout(resizeTimer);
    resizeTimer = setTimeout(function() {
        var bodyW = $(window).width();
        var tableWidth = getTableWidth();
        var tableHeight = getTableHeight();
        var fixedConfig = getFixedColumnsConfig(bodyW);

        // Update table width
        table.bootstrapTable('resetView', {
            width: tableWidth
        });

        // Responsive height control
        if (fixedConfig.fixedHeight) {
            table.bootstrapTable('resetView', {
                height: tableHeight
            });
        } else {
            table.bootstrapTable('resetView', {
                height: undefined
            });
        }

        // Reinitialize if fixed columns changed
        var currentOptions = table.bootstrapTable('getOptions');
        if (currentOptions.fixedNumber !== fixedConfig.fixedNumber ||
            currentOptions.fixedRightNumber !== fixedConfig.fixedRightNumber) {
            var currentData = table.bootstrapTable('getData');
            optionsInit.fixedColumns = fixedConfig.fixedColumns;
            optionsInit.fixedNumber = fixedConfig.fixedNumber;
            optionsInit.fixedRightNumber = fixedConfig.fixedRightNumber;
            optionsInit.height = fixedConfig.fixedHeight ? tableHeight : undefined;
            optionsInit.showColumns = fixedConfig.showColumns;
            optionsInit.showExport = fixedConfig.showExport;
            table.bootstrapTable('destroy');
            table.bootstrapTable(optionsInit);
            table.bootstrapTable('load', currentData);
        }
    }, 200); // 200ms debounce
}
```

### 6. Event Binding Pattern

Bind all relevant events to the unified reset function:

```javascript
// Initialize table
table.bootstrapTable(optionsInit);

// Window resize (debounced)
$(window).on('resize', resetTableView);

// Data load complete
table.on('load-success.bs.table', function (e, data) {
    resetTableView();
});

// Search form toggle
$(document).on('click', '.btn-search-toggle', function() {
    setTimeout(resetTableView, 300);
});
```

## Complete Implementation Example

```javascript
index: function () {
    Table.api.init({
        extend: {
            index_url: 'controller/index' + location.search,
            add_url: 'controller/add',
            edit_url: 'controller/edit',
            del_url: 'controller/del',
            table: 'table_name',
        }
    });

    var table = $("#table");

    // Bootstrap standard breakpoints
    const BREAKPOINT_SM = 576;
    const BREAKPOINT_MD = 768;
    const BREAKPOINT_LG = 992;
    const BREAKPOINT_XL = 1200;

    // Dynamic fixed column configuration
    function getFixedColumnsConfig(bodyW) {
        if (bodyW < BREAKPOINT_SM) {
            return {
                fixedColumns: false,
                fixedNumber: 0,
                fixedRightNumber: 0,
                showColumns: false,
                showExport: false,
                fixedHeight: false
            };
        } else if (bodyW < BREAKPOINT_MD) {
            return {
                fixedColumns: true,
                fixedNumber: 2,
                fixedRightNumber: 0,
                showColumns: false,
                showExport: false,
                fixedHeight: false
            };
        } else if (bodyW < BREAKPOINT_LG) {
            return {
                fixedColumns: true,
                fixedNumber: 3,
                fixedRightNumber: 0,
                showColumns: true,
                showExport: true,
                fixedHeight: true
            };
        } else if (bodyW < BREAKPOINT_XL) {
            return {
                fixedColumns: true,
                fixedNumber: 4,
                fixedRightNumber: 1,
                showColumns: true,
                showExport: true,
                fixedHeight: true
            };
        } else {
            return {
                fixedColumns: true,
                fixedNumber: 5,
                fixedRightNumber: 1,
                showColumns: true,
                showExport: true,
                fixedHeight: true
            };
        }
    }

    // Precise height calculation
    function getTableHeight() {
        var bodyH = $(window).height();
        var h_ribbon = $('#ribbon').outerHeight(true) || 0;
        var h_panelHeading = $('.panel-heading').outerHeight(true) || 0;
        var h_toolbar = $('.fixed-table-toolbar').outerHeight(true) || 0;
        // Search form height NOT included - it's expandable and should not affect table height
        var h_searchForm = 0;
        var h_pagination = $('.fixed-table-pagination').outerHeight(true) || 40;
        var margin = 0;
        var calculatedHeight = bodyH - h_ribbon - h_panelHeading - h_toolbar - h_searchForm - h_pagination - margin;
        // Set minimum height to ensure at least 10 rows of data (approximately 400px)
        var minHeight = 400;
        return Math.max(calculatedHeight, minHeight);
    }

    // Accurate width calculation
    function getTableWidth() {
        var bodyW = $(window).width();
        var panelPadding = 30;
        return bodyW - panelPadding;
    }

    var bodyW = $(window).width();
    var fixedConfig = getFixedColumnsConfig(bodyW);

    var optionsInit = {
        url: $.fn.bootstrapTable.defaults.extend.index_url,
        pk: 'id',
        sortName: 'id',
        showColumns: fixedConfig.showColumns,
        showExport: fixedConfig.showExport,
        fixedColumns: fixedConfig.fixedColumns,
        fixedNumber: fixedConfig.fixedNumber,
        fixedRightNumber: fixedConfig.fixedRightNumber,
        searchFormTemplate: 'consultformtpl',
        height: fixedConfig.fixedHeight ? getTableHeight() : undefined,
        width: getTableWidth(),
        columns: [/* ... */],
        queryParams: function (params) {
            return params;
        }
    };

    table.bootstrapTable(optionsInit);

    // Unified reset with debounce
    var resizeTimer;
    function resetTableView() {
        clearTimeout(resizeTimer);
        resizeTimer = setTimeout(function() {
            var bodyW = $(window).width();
            var tableWidth = getTableWidth();
            var tableHeight = getTableHeight();
            var fixedConfig = getFixedColumnsConfig(bodyW);

            table.bootstrapTable('resetView', {
                width: tableWidth
            });

            if (fixedConfig.fixedHeight) {
                table.bootstrapTable('resetView', {
                    height: tableHeight
                });
            } else {
                table.bootstrapTable('resetView', {
                    height: undefined
                });
            }

            var currentOptions = table.bootstrapTable('getOptions');
            if (currentOptions.fixedNumber !== fixedConfig.fixedNumber ||
                currentOptions.fixedRightNumber !== fixedConfig.fixedRightNumber) {
                var currentData = table.bootstrapTable('getData');
                optionsInit.fixedColumns = fixedConfig.fixedColumns;
                optionsInit.fixedNumber = fixedConfig.fixedNumber;
                optionsInit.fixedRightNumber = fixedConfig.fixedRightNumber;
                optionsInit.height = fixedConfig.fixedHeight ? tableHeight : undefined;
                optionsInit.showColumns = fixedConfig.showColumns;
                optionsInit.showExport = fixedConfig.showExport;
                table.bootstrapTable('destroy');
                table.bootstrapTable(optionsInit);
                table.bootstrapTable('load', currentData);
            }
        }, 200);
    }

    $(window).on('resize', resetTableView);
    table.on('load-success.bs.table', function (e, data) {
        resetTableView();
    });
    $(document).on('click', '.btn-search-toggle', function() {
        setTimeout(resetTableView, 300);
    });

    Table.api.bindevent(table);
}
```

## Common Issues and Solutions

### Issue: Columns misaligned after search

**Cause**: Fixed columns don't recalculate when DOM changes (search form expansion)

**Solution**: Bind `load-success.bs.table` event to call `resetTableView()`

### Issue: Fixed columns overlap on mobile

**Cause**: Fixed columns count too high for small screens

**Solution**: Use `getFixedColumnsConfig()` to dynamically reduce fixed columns on smaller screens

### Issue: Table height cuts off content

**Cause**: Hardcoded height values or missing margin calculations

**Solution**: Use `getTableHeight()` with `outerHeight(true)` to account for all visible elements

### Issue: Table height disappears when search form expands

**Cause**: Search form height is included in calculation, reducing available space

**Solution**: Set `h_searchForm = 0` to exclude search form from height calculation, use minimum height (400px) to ensure data visibility

### Issue: Table width causes horizontal scrollbar

**Cause**: Incorrect width calculation or missing panel padding

**Solution**: Use `getTableWidth()` accounting for panel padding (typically 30px)

### Issue: Frequent re-rendering on resize

**Cause**: No debounce on resize event

**Solution**: Use 200ms debounce in `resetTableView()` to batch resize events

### Issue: 14-inch laptop shows insufficient table height

**Cause**: No minimum height constraint, search form expansion reduces available space

**Solution**: Set `minHeight = 400` in `getTableHeight()` to guarantee at least 10 rows of data are visible

## Testing Checklist

After implementing table optimizations:

- [ ] Column alignment remains correct after search
- [ ] Fixed columns stay aligned when scrolling horizontally
- [ ] Responsive breakpoints work correctly (test at 575px, 767px, 991px, 1199px)
- [ ] iPad Mini (768px) displays correctly
- [ ] Small mobile devices (< 576px) show no fixed columns
- [ ] Desktop displays full fixed columns
- [ ] Window resize debounces correctly (no performance issues)
- [ ] Height calculation accurate with expanded search form
- [ ] Search conditions expand → table maintains reasonable height
- [ ] Bottom has no extra reserved space (margin = 0)
- [ ] Minimum height guarantees 400px (approx 10 rows of data)
- [ ] At least 10 rows of data visible
- [ ] Small screen devices display normally
- [ ] Auto-adjusts when search form expands/collapses
- [ ] 14-inch laptops show sufficient table height
- [ ] Version number updated in `application/extra/site.php`
