<!-- Редактируемые блоки -->
<div class="editable-section" data-template="modules/text.tpl" data-edit-mode="wysiwyg">
    {include file="modules/text.tpl"}
</div>

<!-- <div class="editable-section" data-template="modules/complex.tpl" data-edit-mode="html">
    {include file="modules/complex.tpl"}
</div> -->

<!-- Модальное окно редактора -->
<div id="editor-modal" class="modal">
    <div class="modal-content">
        <div class="modal-header">
            <h3 class="modal-title">Редактирование контента</h3>
            <button id="toggle-mode" class="mode-toggle">Переключить в HTML</button>
            <button id="close-editor" class="close">&times;</button>
        </div>
        <div id="editor"></div>
        <textarea id="html-editor" style="display: none; width: 100%; min-height: 300px; font-family: monospace; padding: 10px;"></textarea>
        <div class="modal-footer">
            <button id="save-btn">Сохранить</button>
        </div>
        <div id="loader" class="loader" style="display: none;"></div>
    </div>
</div>



<!-- 📚 Подключение стилей и скриптов -->
<link href="https://cdn.quilljs.com/1.3.6/quill.snow.css" rel="stylesheet">
<script src="https://cdn.quilljs.com/1.3.6/quill.js"></script>
<script src="https://unpkg.com/htmx.org@1.9.12"></script>

<style>
/* Стили для редактируемых элементов */
[data-editable] {
    position: relative;
    transition: all 0.3s ease;
}

[data-editable]::after {
    content: '';
    position: absolute;
    right: -40px;
    top: 50%;
    transform: translateY(-50%);
    width: 32px;
    height: 32px;
    background: rgba(52, 152, 219, 0.9);
    border-radius: 50%;
    opacity: 0;
    transition: all 0.3s ease;
    backdrop-filter: blur(4px);
    box-shadow: 0 2px 8px rgba(0,0,0,0.15);
    cursor: pointer;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='white' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M17 3a2.85 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z'%3E%3C/path%3E%3C/svg%3E");
    background-position: center;
    background-repeat: no-repeat;
    background-size: 16px;
    z-index: 000;
}

[data-editable]:hover::after {
    opacity: 1;
    right: -45px;
}

/* Специальные стили для сложных элементов */
[data-editable][data-complex="true"]::after {
    background: rgba(155, 89, 182, 0.9);
}

/* Эффект при наведении на элемент */
[data-editable]:hover {
    outline: 2px dashed rgba(52, 152, 219, 0.3);
    outline-offset: 2px;
}

/* Анимация при клике */
[data-editable]:active::after {
    transform: translateY(-50%) scale(0.95);
}

/* Контейнер для иконки редактирования */
.edit-icon-container {
    position: relative;
    z-index: 1000;
}

/* Адаптивность для мобильных устройств */
@media (max-width: 768px) {
    [data-editable]::after {
        width: 28px;
        height: 28px;
        background-size: 14px;
    }
    
    [data-editable]:hover::after {
        right: -35px;
    }
}

/* Модальное окно */
.modal {
    display: none;
    position: fixed;
    z-index: 1000;
    left: 0;
    top: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.5);
    backdrop-filter: blur(5px);
    display: flex;
    align-items: center;
    justify-content: center;
    opacity: 0;
    visibility: hidden;
    transition: opacity 0.3s, visibility 0.3s;
}

.modal.active {
    opacity: 1;
    visibility: visible;
}

.modal-content {
    background: white;
    padding: 30px;
    border-radius: 12px;
    box-shadow: 0 8px 32px rgba(0,0,0,0.1);
    width: 90%;
    max-width: 800px;
    position: relative;
    transform: translateY(-20px);
    transition: transform 0.3s;
}

.modal.active .modal-content {
    transform: translateY(0);
}

/* Заголовок модального окна */
.modal-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 20px;
}

.modal-title {
    font-size: 1.5rem;
    font-weight: 600;
    color: #333;
}

/* Кнопка закрытия */
.close {
    position: absolute;
    right: 20px;
    top: 20px;
    width: 30px;
    height: 30px;
    background: #f5f5f5;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 0.3s ease;
    border: none;
    font-size: 20px;
    color: #666;
}

.close:hover {
    background: #e0e0e0;
    transform: rotate(90deg);
}

/* Контейнер редактора */
#editor {
    flex: 1; 
    max-height: calc(90vh - 200px);
    overflow-y: auto;
    margin: 20px 0;
    border-radius: 8px; 
}

/* Футер модального окна */
.modal-footer {
    display: flex;
    justify-content: flex-end;
    padding-top: 20px;
    border-top: 1px solid #e0e0e0;
}

/* Кнопка сохранения */
#save-btn {
    padding: 12px 24px;
    background: #4CAF50;
    color: white;
    border: none;
    border-radius: 6px;
    font-size: 16px;
    cursor: pointer;
    transition: all 0.3s ease;
}

#save-btn:hover {
    background: #45a049;
    transform: translateY(-1px);
    box-shadow: 0 2px 8px rgba(76, 175, 80, 0.3);
}

/* Индикатор загрузки */
.loader {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 40px;
    height: 40px;
    border: 4px solid #f3f3f3;
    border-top: 4px solid #4CAF50;
    border-radius: 50%;
    animation: spin 1s linear infinite;
}

/* Анимации */
@keyframes modalFadeIn {
    from {
        opacity: 0;
        transform: translateY(-20px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

@keyframes spin {
    0% { transform: translate(-50%, -50%) rotate(0deg); }
    100% { transform: translate(-50%, -50%) rotate(360deg); }
}

/* Медиа-запросы для адаптивности */
@media (max-width: 768px) {
    .modal-content {
        padding: 20px;
        width: 95%;
    }

    .modal {
        padding: 10px;
    }

    #editor {
        min-height: 200px;
    }

    .modal-title {
        font-size: 1.2rem;
    }

    #save-btn {
        padding: 10px 20px;
        font-size: 14px;
    }
}

/* Стили для редактора Quill */
.ql-toolbar {
    border-top-left-radius: 8px;
    border-top-right-radius: 8px;
    background: #f8f9fa;
    border-bottom: 1px solid #e0e0e0;
}

.ql-container {
    border-bottom-left-radius: 8px;
    border-bottom-right-radius: 8px;
    background: white;
}

.ql-editor {
    font-size: 16px;
    line-height: 1.6;
    color: #333;
    padding: 20px;
}

/* Стили для уведомлений */
.notification {
    position: fixed;
    top: 20px;
    right: 20px;
    padding: 15px 25px;
    border-radius: 8px;
    color: white;
    font-size: 14px;
    z-index: 9999;
    opacity: 0;
    transform: translateY(-20px);
    transition: all 0.3s ease;
}

.notification.show {
    opacity: 1;
    transform: translateY(0);
}

.notification.success {
    background-color: #4CAF50;
    box-shadow: 0 4px 15px rgba(76, 175, 80, 0.3);
}

.notification.error {
    background-color: #f44336;
    box-shadow: 0 4px 15px rgba(244, 67, 54, 0.3);
}

.mode-toggle {
    padding: 8px 16px;
    background: #f0f0f0;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    margin-right: 20px;
    transition: background-color 0.3s;
}

.mode-toggle:hover {
    background: #e0e0e0;
}

#html-editor {
    border: 1px solid #ccc;
    border-radius: 4px;
    resize: vertical;
    line-height: 1.5;
    tab-size: 2;
}
</style>

<script>
let quill = null;
let observer = null;
let currentTemplate = 'modules/text.tpl';
let currentEditableSection = null;
let currentEditMode = 'wysiwyg';

// Инициализация при загрузке страницы
document.addEventListener('DOMContentLoaded', () => {
    // Находим все редактируемые элементы
    makeElementsEditable();
});

function makeElementsEditable() {
    // Расширяем список селекторов для редактируемых элементов
    const elements = document.querySelectorAll(`
        [class*="text-anime"],
        [data-cursor],
        h1, h2, h3, h4, h5, h6,
        p,
        div.editable,
        .section-title-content,
        .pricing-title h3,
        .pricing-title p,
        .pricing-list li,
        .pricing-btn a,
        ul[itemprop="serviceIncludes"] li
    `);
    
    elements.forEach(element => {
        if (element.closest('#editor-modal')) {
            return;
        }
        
        element.removeEventListener('click', handleElementClick);
        
        const children = element.querySelectorAll('[data-editable]');
        children.forEach(child => {
            child.removeEventListener('click', handleElementClick);
            child.removeAttribute('data-editable');
            child.style.cursor = 'inherit';
        });
        
        // Определяем тип элемента
        const isComplex = isComplexElement(element);
        const isListItem = element.tagName === 'LI';
        const isLink = element.tagName === 'A';
        
        if (shouldBeEditable(element)) {
            element.setAttribute('data-editable', 'true');
            element.style.cursor = 'pointer';
            
            if (isComplex) {
                element.setAttribute('data-complex', 'true');
            }
            
            if (isListItem) {
                element.setAttribute('data-list-item', 'true');
            }
            
            if (isLink) {
                element.setAttribute('data-link', 'true');
            }
            
            element.addEventListener('click', handleElementClick);
        }
    });
}

function isComplexElement(element) {
    return element.classList.contains('text-anime-style-2') ||
           element.hasAttribute('data-cursor') ||
           element.querySelector('span, div, strong, em, i, b') !== null ||
           element.closest('.pricing-list') !== null;
}

function shouldBeEditable(element) {
    return element.classList.contains('section-title-content') ||
           /^h[1-6]$/i.test(element.tagName) ||
           element.tagName === 'P' ||
           element.tagName === 'LI' ||
           (element.tagName === 'A' && element.classList.contains('btn-highlighted')) ||
           element.classList.contains('text-anime-style-2') ||
           element.hasAttribute('data-cursor') ||
           (element.children.length === 0 && element.textContent.trim()) ||
           element.closest('.pricing-list') !== null;
}

function handleElementClick(event) {
    event.preventDefault();
    event.stopPropagation();
    
    const element = event.target.closest('[data-editable]');
    if (!element) return;
    
    currentEditableSection = element;
    
    // Определяем режим редактирования
    let editMode = 'wysiwyg';
    if (element.hasAttribute('data-complex')) {
        editMode = 'html';
    }
    
    // Получаем контент для редактирования
    let content;
    if (element.hasAttribute('data-list-item')) {
        content = element.innerHTML;
    } else if (element.hasAttribute('data-link')) {
        content = element.textContent;
    } else if (element.hasAttribute('data-complex')) {
        content = element.outerHTML;
    } else {
        content = element.textContent || element.innerText;
    }
    
    openEditor(currentTemplate, content, element, editMode);
}

function destroyQuill() {
    if (observer) {
        observer.disconnect();
        observer = null;
    }
    
    // Полностью удаляем все элементы Quill
    const editor = document.getElementById('editor');
    if (editor) {
        // Удаляем все панели инструментов
        const toolbars = document.querySelectorAll('.ql-toolbar');
        toolbars.forEach(toolbar => toolbar.remove());
        
        // Удаляем все контейнеры редактора
        const containers = document.querySelectorAll('.ql-container');
        containers.forEach(container => container.remove());
        
        editor.innerHTML = '';
    }
    
    quill = null;
}

function initQuill() {
    const container = document.getElementById('editor');
    if (!container) return;

    // Удаляем все существующие панели инструментов и контейнеры Quill
    const existingToolbars = document.querySelectorAll('.ql-toolbar');
    existingToolbars.forEach(toolbar => toolbar.remove());
    
    const existingContainers = document.querySelectorAll('.ql-container');
    existingContainers.forEach(container => container.remove());

    // Очищаем контейнер
    container.innerHTML = '';

    // Создаем новый div для редактора
    const editorDiv = document.createElement('div');
    container.appendChild(editorDiv);

    const toolbarOptions = [
        ['bold', 'italic', 'underline'],
        [{ 'header': [1, 2, 3, false] }],
        [{ 'color': [] }, { 'background': [] }],
        [{ 'align': [] }],
        ['clean']
    ];

    try {
        // Уничтожаем предыдущий экземпляр Quill
        if (quill) {
            quill = null;
        }

        // Создаем новый экземпляр Quill
        quill = new Quill(editorDiv, {
            modules: {
                toolbar: toolbarOptions,
                clipboard: {
                    matchVisual: false
                },
                history: {
                    delay: 2000,
                    maxStack: 500,
                    userOnly: true
                }
            },
            theme: 'snow',
            placeholder: 'Введите текст...',
            bounds: '#editor-modal'
        });

        // Настройка стилей
        quill.root.style.color = '#333';
        quill.root.style.minHeight = '200px';
        
        // Показываем контейнер редактора
        container.style.display = 'block';

    } catch (error) {
        console.error('Ошибка инициализации Quill:', error);
    }
}

function initEditor(mode = 'wysiwyg') {
    currentEditMode = mode;
    const editorContainer = document.getElementById('editor');
    const htmlEditor = document.getElementById('html-editor');
    
    if (mode === 'wysiwyg') {
        editorContainer.style.display = 'block';
        htmlEditor.style.display = 'none';
        initQuill();
    } else {
        editorContainer.style.display = 'none';
        htmlEditor.style.display = 'block';
        if (quill) {
            destroyQuill();
        }
    }
}

function openEditor(template, content, element, mode) {
    currentTemplate = template;
    currentEditableSection = element;
    currentEditMode = mode;
    
    const modal = document.getElementById('editor-modal');
    const htmlEditor = document.getElementById('html-editor');
    const wysiwygEditor = document.getElementById('editor');
    
    modal.style.display = 'flex';
    
    requestAnimationFrame(() => {
        modal.classList.add('active');
        
        if (mode === 'html') {
            // Для сложных элементов показываем HTML из файла
            htmlEditor.value = content;
            htmlEditor.style.display = 'block';
            wysiwygEditor.style.display = 'none';
            document.getElementById('toggle-mode').style.display = 'none';
        } else {
            // Для простых элементов оставляем как есть
            wysiwygEditor.style.display = 'block';
            htmlEditor.style.display = 'none';
            document.getElementById('toggle-mode').style.display = 'block';
            
            initQuill();
            if (quill) {
                quill.root.innerHTML = content;
            }
        }
    });
}

function toggleEditorMode() {
    const editorContainer = document.getElementById('editor');
    const htmlEditor = document.getElementById('html-editor');
    const toggleBtn = document.getElementById('toggle-mode');
    
    if (currentEditMode === 'wysiwyg') {
        // Переключаемся в HTML режим
        currentEditMode = 'html';
        editorContainer.style.display = 'none';
        htmlEditor.style.display = 'block';
        
        // Берем только текст из редактора, без оберток
        const content = quill ? quill.getText() : '';
        htmlEditor.value = content;
        
        toggleBtn.textContent = 'Переключить в Визуальный';
    } else {
        // Переключаемся в визуальный режим
        currentEditMode = 'wysiwyg';
        editorContainer.style.display = 'block';
        htmlEditor.style.display = 'none';
        toggleBtn.textContent = 'Переключить в HTML';
        
        initQuill();
        if (quill) {
            quill.setText(htmlEditor.value);
        }
    }
}

// Получаем текущий контент из активного редактора
function getCurrentContent() {
    if (currentEditMode === 'wysiwyg' && quill) {
        return quill.root.innerHTML;
    } else {
        return document.getElementById('html-editor').value;
    }
}

// Обновляем состояние переключателя режимов
function updateEditorModeToggle(mode) {
    const toggleBtn = document.getElementById('toggle-mode');
    if (toggleBtn) {
        toggleBtn.textContent = mode === 'wysiwyg' ? 'Переключить в HTML' : 'Переключить в Визуальный';
    }
}

function closeEditor() {
    const modal = document.getElementById('editor-modal');
    modal.classList.remove('active');
    
    // Отключаем observer
    if (observer) {
        observer.disconnect();
        observer = null;
    }
    
    setTimeout(() => {
        modal.style.display = 'none';
        
        // Очищаем редактор
        const editorContainer = document.getElementById('editor');
        if (editorContainer) {
            editorContainer.innerHTML = '';
        }
        
        // Уничтожаем экземпляр Quill
        if (quill) {
            quill = null;
        }
        
        currentEditableSection = null;
    }, 300);
}

// Сохранение контента
function saveContent() {
    if (!currentEditableSection) return;

    const loader = document.getElementById('loader');
    loader.style.display = 'block';

    let content;
    const isComplex = currentEditableSection.hasAttribute('data-complex');
    const isList = currentEditableSection.hasAttribute('data-list-item');
    const isLink = currentEditableSection.hasAttribute('data-link');

    if (currentEditMode === 'html') {
        content = document.getElementById('html-editor').value;
    } else {
        content = quill.getText().trim();
    }

    const data = {
        content: content,
        template: currentTemplate,
        selector: getSelectorPath(currentEditableSection),
        originalContent: currentEditableSection.outerHTML,
        isComplex: isComplex,
        isList: isList,
        isLink: isLink,
        tagName: currentEditableSection.tagName.toLowerCase()
    };

    fetch('/engine/ajax/editor/save-content.php', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(data)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            if (isComplex) {
                location.reload();
            } else if (isList || isLink) {
                currentEditableSection.innerHTML = content;
            } else {
                currentEditableSection.textContent = content;
            }
            closeEditor();
            showNotification('Изменения успешно сохранены', 'success');
        } else {
            throw new Error(data.message || 'Ошибка сохранения');
        }
    })
    .catch(error => {
        console.error('Ошибка:', error);
        showNotification('Ошибка при сохранении: ' + error.message, 'error');
    })
    .finally(() => {
        loader.style.display = 'none';
    });
}

// Функция для получения уникального селектора элемента
function getSelectorPath(element) {
    let path = [];
    while (element && element.nodeType === Node.ELEMENT_NODE) {
        let selector = element.tagName.toLowerCase();
        
        if (element.id) {
            selector += '#' + element.id;
            path.unshift(selector);
            break;
        } else {
            let sibling = element;
            let nth = 1;
            
            while (sibling = sibling.previousElementSibling) {
                if (sibling.tagName === element.tagName) nth++;
            }
            
            if (nth > 1) selector += `:nth-of-type(${nth})`;
        }
        
        path.unshift(selector);
        element = element.parentNode;
    }
    
    return path.join(' > ');
}

// Функция для показа уведомлений
function showNotification(message, type = 'success') {
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.textContent = message;
    
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.classList.add('show');
    }, 100);
    
    setTimeout(() => {
        notification.classList.remove('show');
        setTimeout(() => notification.remove(), 300);
    }, 3000);
}

// Инициализация при загрузке страницы
document.addEventListener('DOMContentLoaded', () => {
    // Находим все элементы с классом text-anime-style-2 и другие потенциально сложные элементы
    const elements = document.querySelectorAll('[class*="text-anime"], [data-cursor], h1, h2, h3, h4, h5, h6, p');
    
    elements.forEach(element => {
        if (detectEditMode(element) === 'html') {
            // Добавляем обработчик только для сложных элементов
            element.addEventListener('click', handleElementClick);
            // Добавляем визуальную индикацию редактируемости
            element.style.cursor = 'pointer';
            element.setAttribute('data-editable', 'true');
        }
    });
    
    const modal = document.getElementById('editor-modal');
    modal.style.display = 'none';
    modal.classList.remove('active');
    
    document.getElementById('save-btn')?.addEventListener('click', saveContent);
    document.getElementById('close-editor')?.addEventListener('click', closeEditor);
    document.getElementById('toggle-mode')?.addEventListener('click', toggleEditorMode);
    
    // Скрываем прелоадер при загрузке
    const loader = document.getElementById('loader');
    if (loader) {
        loader.style.display = 'none';
    }
});

// Добавляем функцию определения режима редактирования
function detectEditMode(element) {
    // Проверяем является ли элемент сложным
    if (element.classList.contains('text-anime-style-2') || 
        element.hasAttribute('data-cursor') ||
        element.querySelector('span, div, strong, em, i, b') !== null ||
        element.closest('.pricing-list') !== null) {
        return 'html';
    }
    
    // Для простых элементов
    if (element.tagName === 'P' || 
        /^h[1-6]$/i.test(element.tagName) ||
        element.tagName === 'LI' ||
        (element.tagName === 'A' && element.classList.contains('btn-highlighted')) ||
        (element.children.length === 0 && element.textContent.trim())) {
        return 'wysiwyg';
    }
    
    // По умолчанию
    return 'wysiwyg';
}

</script>
<script>
    // Функция для определения сложных элементов
function isComplexElement(element) {
    return element.hasAttribute('data-complex') || 
           element.classList.contains('text-anime-style-2') ||
           element.hasAttribute('data-cursor') ||
           element.querySelector('span, div, strong, em, i, b') !== null;
}

 

// Инициализация редактора для сложных элементов
document.addEventListener('DOMContentLoaded', () => {
    const elements = document.querySelectorAll('.editable-section');
    
    elements.forEach(element => {
        if (isComplexElement(element)) {
            element.addEventListener('click', async (e) => {
                e.preventDefault();
                e.stopPropagation();

                const template = element.getAttribute('data-template');
                if (!template) return;

                try {
                    const response = await loadOriginalContent(template, element);
                    if (response.success) {
                        const newContent = prompt('Редактировать HTML:', response.content);
                        if (newContent !== null) {
                            const saveResponse = await saveComplexContent(template, newContent, element);
                            if (saveResponse.success) {
                                element.outerHTML = newContent;
                                alert('Изменения сохранены!');
                            }
                        }
                    }
                } catch (error) {
                    console.error('Ошибка:', error);
                }
            });
        }
    });
});
</script>
