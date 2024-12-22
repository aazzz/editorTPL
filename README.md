# In-Place Content Editor
Простой редактор контента для прямого редактирования текста на странице. Поддерживает простые текстовые элементы и сложные HTML структуры.
## Установка
1. Скопируйте файлы:
/engine/ajax/editor/
── get-element-source.php   # Загрузка оригинального контента из TPL
── save-content.php        # Сохранение изменений
/templates/Default/modules/
── edit.tpl               # Основной файл редактора
2. Подключите в шаблон:
```html
link href="path/to/quill.snow.css" rel="stylesheet">
script src="path/to/quill.min.js"></script>
include file="modules/edit.tpl"}
``
## Использование
### Простые элементы
``html
!-- Автоматически становятся редактируемыми -->
p>Редактируемый текст</p>
h1>Заголовок</h1>
h3 class="wow fadeInUp">Простой заголовок</h3>
``
### Сложные элементы
``html
!-- Редактируются в HTML режиме -->
h2 class="text-anime-style-2" data-cursor="-opaque">
   Текст с <span>форматированием</span>
/h2>
<div class="section-title-content">
   Контент с форматированием
/div>
``
## Поддерживаемые элементы
 h1-h6 (включая элементы с классами wow, fadeInUp)
 p
 .text-anime-style-2
 [data-cursor]
 .section-title-content
 Элементы с вложенными тегами (span, div, strong, em, i, b)
## Режимы редактирования
 WYSIWYG - для простого текста (параграфы, заголовки)
 HTML - для сложных элементов (с вложенными тегами)
## Особенности
 Сложные элементы загружаются из TPL файлов для сохранения структуры
 Автоматическое определение типа элемента и режима редактирования
 Визуальная индикация редактируемых областей
 Поддержка анимированных элементов (wow, fadeInUp)
 Сохранение атрибутов и классов при редактировании
## JavaScript функции
 makeElementsEditable() - инициализация редактируемых элементов
 handleElementClick() - обработка клика по элементу
 openEditor() - открытие редактора
 saveContent() - сохранение изменений
 toggleEditorMode() - переключение между WYSIWYG и HTML режимами
## Требования
 jQuery
 Quill Editor
 PHP 7.0+
