# editorTPL
# In-Place Content Editor

Простой редактор контента для прямого редактирования текста на странице. Поддерживает простые текстовые элементы и сложные HTML структуры.

## Установка

1. Скопируйте файлы: `edit.tpl`, `text.tpl` в папку вашего шаблона.
2. Вставьте в нужный вам элемент HTML код:

```html
<div data-template="text">
    <div class="container">
        <div class="row section-row align-items-center">
            <div class="col-lg-7">
                <div class="section-title">
                    <h3 class="wow fadeInUp">why choose</h3>
                    <h2 class="text-anime-style-2" data-cursor="-opaque">Expertise for <span>your digital</span> growth journey</h2>
                </div>
            </div>
        </div>
    </div>
</div>
```

2. Подключите в шаблон:

```html
<link href="path/to/quill.snow.css" rel="stylesheet">
<script src="path/to/quill.min.js"></script>
{include file="modules/edit.tpl"}
```

## Использование

### Простые элементы
```

<p>Редактируемый текст</p>
<h1>Заголовок</h1>
```

### Сложные элементы
```

<h2 class="text-anime-style-2" data-cursor="-opaque">
    Текст с <span>форматированием</span>
</h2>
```

## Поддерживаемые элементы
- h1-h6
- p
- .text-anime
- [data-cursor]
- .section-title-content
- Элементы с вложенными тегами (span, div, strong, em, i, b)

## Режимы
- WYSIWYG - для простого текста
- HTML - для сложных элементов

## Особенности
- Сложные элементы загружаются из TPL файлов
- Автоопределение типа элемента
- Визуальная индикация редактируемых областей

## Требования
- jQuery
- Quill Editor
- PHP 7.0+
