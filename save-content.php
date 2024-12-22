<?php
header('Content-Type: application/json');

try {
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['template']) || !isset($data['content'])) {
        throw new Exception('Required parameters missing');
    }

    $templatePath = $_SERVER['DOCUMENT_ROOT'] . '/templates/Default/' . $data['template'];
    
    if (!file_exists($templatePath)) {
        throw new Exception('Template file not found');
    }

    // Читаем текущее содержимое файла
    $fileContent = file_get_contents($templatePath);
    
    if ($fileContent === false) {
        throw new Exception('Failed to read template file');
    }

    if ($data['isComplex']) {
        // Для сложных элементов (например, h2 с text-anime-style-2)
        $pattern = '/<h2[^>]*class="[^"]*text-anime-style-2[^"]*"[^>]*>.*?<\/h2>/s';
        $newContent = preg_replace($pattern, $data['content'], $fileContent);
    } else {
        // Для простых элементов
        $tagName = $data['tagName'];
        
        // Получаем текст элемента для точной идентификации
        $originalText = strip_tags($data['originalContent']);
        
        // Создаем массив для хранения всех совпадений
        $matches = [];
        $positions = [];
        
        // Ищем все элементы данного типа
        $pattern = "/<{$tagName}[^>]*>(.*?)<\/{$tagName}>/s";
        preg_match_all($pattern, $fileContent, $matches, PREG_OFFSET_CAPTURE);
        
        // Находим нужный элемент по его содержимому
        $foundIndex = -1;
        foreach ($matches[0] as $index => $match) {
            if (strip_tags($match[0]) === $originalText) {
                $foundIndex = $index;
                break;
            }
        }
        
        if ($foundIndex === -1) {
            // Если точное совпадение не найдено, пробуем найти по атрибутам
            foreach ($matches[0] as $index => $match) {
                preg_match('/<' . $tagName . '([^>]*)>/', $match[0], $attrMatch);
                if (isset($attrMatch[1]) && strpos($data['originalContent'], $attrMatch[1]) !== false) {
                    $foundIndex = $index;
                    break;
                }
            }
        }
        
        if ($foundIndex === -1) {
            throw new Exception('Element not found in template');
        }
        
        // Сохраняем атрибуты оригинального элемента
        preg_match('/<' . $tagName . '([^>]*)>/', $data['originalContent'], $attrMatch);
        $originalAttrs = isset($attrMatch[1]) ? $attrMatch[1] : '';
        
        // Создаем новый элемент
        $newElement = "<{$tagName}{$originalAttrs}>" . $data['content'] . "</{$tagName}>";
        
        // Заменяем только найденный элемент
        $position = $matches[0][$foundIndex][1];
        $length = strlen($matches[0][$foundIndex][0]);
        $newContent = substr_replace($fileContent, $newElement, $position, $length);
    }

    if ($newContent === null) {
        throw new Exception('Failed to replace content');
    }

    if (file_put_contents($templatePath, $newContent) === false) {
        throw new Exception('Failed to save changes');
    }

    echo json_encode(['success' => true]);

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}
?>
