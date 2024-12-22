<?php
header('Content-Type: application/json');

try {
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['template']) || !isset($data['selector'])) {
        throw new Exception('Required parameters missing');
    }

    $templatePath = $_SERVER['DOCUMENT_ROOT'] . '/templates/Default/' . $data['template'];
    
    if (!file_exists($templatePath)) {
        throw new Exception('Template file not found');
    }

    // Читаем файл шаблона
    $content = file_get_contents($templatePath);
    
    // Создаем более гибкий паттерн для поиска элемента
    $selector = preg_quote($data['selector'], '/');
    $pattern = '/' . $selector . '/s';
    preg_match($pattern, $content, $matches);
    
    if (!empty($matches[0])) {
        echo json_encode([
            'success' => true,
            'content' => $matches[0]
        ]);
    } else {
        // Если точное совпадение не найдено, пробуем найти по классу и атрибутам
        $pattern = '/<h2[^>]*class="[^"]*text-anime-style-2[^"]*"[^>]*>.*?<\/h2>/s';
        preg_match($pattern, $content, $matches);
        
        if (!empty($matches[0])) {
            echo json_encode([
                'success' => true,
                'content' => $matches[0]
            ]);
        } else {
            throw new Exception('Element not found in template');
        }
    }

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
} 