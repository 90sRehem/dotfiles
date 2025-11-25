# Game Development Context

## Core Game Development Patterns

### Game Architecture
- **Game Loop Pattern**: Update game state, render graphics, handle input
- **Entity-Component System**: Separate data (components) from behavior (systems)
- **State Machine Pattern**: Manage game states (menu, playing, paused, game over)

### Common Game Types & Implementation

#### Snake Game
```javascript
// Core components needed:
// - Game board/grid
// - Snake entity (segments array)
// - Food entity
// - Collision detection
// - Score system
// - Direction control

const DIRECTIONS = {
  UP: { x: 0, y: -1 },
  DOWN: { x: 0, y: 1 },
  LEFT: { x: -1, y: 0 },
  RIGHT: { x: 1, y: 0 }
};
```

#### Tetris Game
- Grid-based gameplay
- Piece rotation logic
- Line clearing algorithm
- Level progression system

#### Pong Game
- Paddle movement
- Ball physics (velocity, collision)
- Score tracking
- AI opponent logic

### HTML5 Canvas Essentials

```javascript
// Basic canvas setup
const canvas = document.getElementById('gameCanvas');
const ctx = canvas.getContext('2d');

// Game loop structure
function gameLoop() {
  update();    // Update game state
  render();    // Draw everything
  requestAnimationFrame(gameLoop);
}

// Common drawing functions
function drawRect(x, y, width, height, color) {
  ctx.fillStyle = color;
  ctx.fillRect(x, y, width, height);
}
```

### Input Handling
```javascript
// Keyboard input
document.addEventListener('keydown', (event) => {
  switch(event.key) {
    case 'ArrowUp': 
    case 'w': 
      // Handle up movement
      break;
    // ... other keys
  }
});
```

### Collision Detection
```javascript
// AABB (Axis-Aligned Bounding Box) collision
function checkCollision(rect1, rect2) {
  return rect1.x < rect2.x + rect2.width &&
         rect1.x + rect1.width > rect2.x &&
         rect1.y < rect2.y + rect2.height &&
         rect1.y + rect1.height > rect2.y;
}
```

### Game File Structure
```
game/
├── index.html          # Main HTML file
├── css/
│   └── style.css       # Game styling
├── js/
│   ├── game.js         # Main game logic
│   ├── entities/       # Game objects
│   │   ├── snake.js
│   │   └── food.js
│   └── utils/
│       ├── input.js    # Input handling
│       └── collision.js # Collision detection
└── assets/
    ├── images/         # Sprites, textures
    └── sounds/         # Audio files
```

### Performance Considerations
- Use `requestAnimationFrame` for smooth animation
- Implement object pooling for frequently created/destroyed objects
- Optimize rendering (only redraw changed areas when possible)
- Use efficient data structures for collision detection

### Game Libraries (Optional)
- **Phaser.js**: Full-featured game framework
- **PixiJS**: 2D WebGL renderer
- **Three.js**: 3D graphics library
- **Matter.js**: Physics engine

### Best Practices
1. **Separate concerns**: Keep game logic, rendering, and input separate
2. **Use delta time**: Make game speed independent of framerate
3. **State management**: Implement proper game state handling
4. **Mobile support**: Add touch controls for mobile devices
5. **Responsive design**: Make game work on different screen sizes

### Testing Game Logic
```javascript
// Unit test example for snake movement
function testSnakeMovement() {
  const snake = new Snake([{x: 5, y: 5}]);
  snake.move(DIRECTIONS.RIGHT);
  console.assert(snake.head.x === 6, "Snake should move right");
}
```