//klasa zwiazana z Mario
class Player{

    constructor(scene,x,y){
        this.scene = scene;
        const useDeadZone = false;
        
        this.sprite = scene.physics.add.sprite(x, y, 'atlas').setScale(2);
        this.sprite.setCollideWorldBounds(true);

    scene.cameras.main.setBounds(0, 0, scene.map.widthInPixels, scene.map.heightInPixels).startFollow(this.sprite);

        if (useDeadZone) {
            scene.cameras.main.setDeadzone(scene.game.config.width / 4, scene.game.config.height)
        }

        this.collider = this.scene.physics.add.collider(this.sprite, this.scene.platform);
        return this;
    }

    reFollowPlayer() {
        this.scene.physics.world.bounds.setPosition(this.scene.cameras.main.worldView.x, 0);
    
        if (this.sprite.body.position.x + this.sprite.body.width / 2 > this.scene.cameras.main.midPoint.x &&
            !this.scene.cameras.main._follow) {
            this.scene.cameras.main.startFollow(this.sprite);
        }
    }

    update(input) {
        // Mario idzie w lewo
        if (input.left.isDown) {
            this.sprite.setVelocityX(-200).setFlipX(true);
            this.sprite.body.onFloor() && !this.sprite.isDed && this.sprite.play('run', true);

            this.scene.cameras.main.stopFollow(this.sprite);
    
        // Mario idzie w prawo
        } else if (input.right.isDown) {
            this.sprite.setVelocityX(200).setFlipX(false);
            this.sprite.body.onFloor() && !this.sprite.isDed && this.sprite.play('run', true);

            this.reFollowPlayer();
        } else {
    
        // Mario stoi w miejscu
            this.sprite.setVelocityX(0);
            this.sprite.body.onFloor() && !this.sprite.isDed && this.sprite.play('idle', true);
        }
        
        // Mario skacze
        if ((input.space.isDown && this.sprite.body.onFloor())) {
            this.sprite.setVelocityY(-350);
            this.sprite.play('jump', true);
        }

    }
    die() {
        this.sprite.isDed = true;
        this.sprite.setVelocity(0, -350);
        this.sprite.play('die', true);
        this.sprite.setCollideWorldBounds(false);
    }
}
//klasa zwiazana ze stworkami
class Goomba{
    constructor(scene) {
        this.scene = scene;
        this.goombas = this.scene.physics.add.group();
        this.collider = this.scene.physics.add.collider(this.scene.player.sprite, this.goombas, this.gameOver, null, this);
    
        const goombaObjects = this.scene.map.getObjectLayer('goomba').objects;
    
        for (const goomba of goombaObjects) {
            this.goombas.create(goomba.x, goomba.y - goomba.height, 'atlas').setScale(1.5).setOrigin(0).setDepth(-1);
        }
    
        for (const goomba of this.goombas.children.entries) {
            goomba.direction = 'RIGHT';
            goomba.isDed = false;
        }
    
        this.scene.physics.add.collider(this.goombas, this.scene.platform);
    }
    collideWith(gameObject) {
        this.scene.physics.add.collider(this.goombas, gameObject);
        return this;
    }

    update() {
        for (const goomba of this.goombas.children.entries) {
            if (goomba.body.blocked.right) {
                goomba.direction = 'LEFT';
            }

            if (goomba.body.blocked.left) {
                goomba.direction = 'RIGHT';
            }

            if (goomba.direction === 'RIGHT') {
                goomba.setVelocityX(100);
            } else {
                goomba.setVelocityX(-100);
            }

            !goomba.isDed && goomba.play('goombaRun', true);
        }
    }
    gameOver() {
        if (this.scene.player.sprite.body.touching.down) {
            this.die();
            return;
        }

        this.scene.player.die();
        this.scene.input.keyboard.shutdown();

        this.scene.physics.world.removeCollider(this.scene.player.collider);
        this.scene.physics.world.removeCollider(this.collider);

        setTimeout(() => {
            this.scene.scene.start('GameOver');
        }, 1500);
    }

    die() {
        for (const goomba of this.goombas.children.entries) {
            if (goomba.body.touching.up) {
                goomba.isDed = true;
                goomba.play('goombaDie', true);
                goomba.on('animationcomplete', () => goomba.destroy());

                increaseScore(.5); //gdy bijesz stworki to dostajesz pół punkta

                this.scene.player.sprite.setVelocity(0, -350);
                this.scene.player.sprite.play('jump');
            };
        }
    }
}

class GameOver extends Phaser.Scene{
    constructor () {
        super('GameOver');
    }

    create() {
        this.cameras.main.setBackgroundColor('#000');
        document.getElementsByClassName('game-over')[0].classList.add('game-over_visible');
        document.getElementsByClassName('game-over')[0].innerText+=`\nZebrałes ${document.getElementsByClassName('score-amount')[0].outerText} punktów`;
    }
}

class GameWinner extends Phaser.Scene{
    constructor () {
        super('GameWinner');
    }

    create() {
        this.cameras.main.setBackgroundColor('#000');
        document.getElementsByClassName('game-winner')[0].classList.add('game-winner_visible');
        document.getElementsByClassName('game-winner')[0].innerText+=`\nZebrałes ${document.getElementsByClassName('score-amount')[0].outerText} punktów`;
    }
}

class Flag{
    constructor(scene) {
        const flagObject = scene.map.getObjectLayer('flag').objects[0];
        const flagCoordinates = scene.tileset.texCoordinates[962]; // 962 to id kafelka na mapce
        const flagRoot = scene.platform.getTileAt(75, 23); // gdzie umiescimy flage, pozycja płytki

        this.scene = scene;
        this.sprite = scene.add.tileSprite(flagObject.x, flagObject.y, 16, 16, 'tiles').setOrigin(0, 1).setTilePosition(flagCoordinates.x, flagCoordinates.y);

        flagRoot.setCollisionCallback(() => {
            flagRoot.collisionCallback = null; //zeby callback zadzialal tylko raz

            const particles = scene.add.particles('atlas', 'mario-atlas_13');
            const emitter = particles.createEmitter({
                x: flagObject.x,
                y: flagObject.y - flagObject.height,
                scale:  { start: 1, end: 0 },
                speed:  { min: 50, max: 100 },
                angle:  { min: 0, max: -180 },
                rotate: { min: 0, max: 360 },
                alpha: .5
            });

            scene.tweens.add({
                targets: this.sprite,
                ease: 'Linear',
                y: '+=60',
                duration: 800,
                onComplete: () => emitter.stop()
            });

            setTimeout(() => {
                this.scene.scene.start('GameWinner');
            }, 2500);
            this.scene.input.keyboard.shutdown();
        });   
    }
}

class Coin{
    constructor(scene){
        this.scene=scene;
        this.coins = this.scene.physics.add.group({
            immovable: true,
            allowGravity: false
        })
        const coinObjects = this.scene.map.getObjectLayer('coin').objects;
        
        for (const coin of coinObjects) {
            this.coins.create(coin.x, coin.y, 'atlas').setOrigin(0).setDepth(-1);
        }
    }
    
    collideWith(gameObject) {
        this.scene.physics.add.overlap(this.coins, gameObject, this.collect, null, this);
        return this;
    }

    update(){
        for (const coin of this.coins.children.entries) {
            coin.play('rotate', true);
        }
    }

    collect() {
        for (const coin of this.coins.children.entries) {
            if (!coin.body.touching.none) {
                coin.body.setEnable(false);

                this.scene.tweens.add({
                    targets: coin,
                    ease: 'Power1',
                    scaleX: 0,
                    scaleY: 0,
                    duration: 200,
                    onComplete: () => coin.destroy()
                });
            }
        }
        increaseScore(1);
    }
}

class Game extends Phaser.Scene {

    constructor () {
        super('Game');
    }
    
    preload() {
        this.load.image('tiles','tiles.png');
        this.load.tilemapTiledJSON('map','map.json');
        this.load.atlas('atlas', 'mario-atlas.png', 'mario-atlas.json');

        this.load.on('complete', () => {
            generateAnimations(this);
        });   
     }

    create() {

        this.map = this.make.tilemap({ key: 'map' });
        this.tileset = this.map.addTilesetImage('map-tileset', 'tiles');
        this.platform = this.map.createLayer('platform', this.tileset, 0, 0);
        this.map.createLayer('background', this.tileset, 0, 0);

        this.platform.setCollisionByExclusion([-1,450], true); //flaga pusta lub flaga sciagnieta

        this.player=new Player(this,25,400);
        this.goombas = new Goomba(this).collideWith(this.platform);
        this.coins = new Coin(this).collideWith(this.player.sprite);
        this.flag = new Flag(this);
        this.inputs = this.input.keyboard.createCursorKeys();
    }
    
    update() {
        this.player.update(this.inputs);
        this.goombas.update();
        this.coins.update();
    }  
}

function generateAnimations(scene){
    scene.anims.create({
        key: 'run',
        frames: scene.anims.generateFrameNames('atlas', {
            prefix: 'mario-atlas_',
            start: 1,
            end: 3,
        }),
        frameRate: 10,
        repeat: -1
    });

    scene.anims.create({
        key: 'idle',
        frames: [{ key: 'atlas', frame: 'mario-atlas_0' }],
        frameRate: 10
    });

    scene.anims.create({
        key: 'jump',
        frames: [{ key: 'atlas', frame: 'mario-atlas_4' }],
        frameRate: 10
    });

    scene.anims.create({
        key: 'die',
        frames: [{ key: 'atlas', frame: 'mario-atlas_5' }],
        frameRate: 10
    });
    // stworek
    scene.anims.create({
        key: 'goombaRun',
        frames: scene.anims.generateFrameNames('atlas', {
            prefix: 'mario-atlas_',
            start: 11,
            end: 12,
        }),
        frameRate: 15,
        repeat: -1
    });

    scene.anims.create({
        key: 'goombaDie',
        frames: [{ key: 'atlas', frame: 'mario-atlas_10' }],
        frameRate: 10,
        hideOnComplete: true
    });

    // moneta
    scene.anims.create({
        key: 'rotate',
        frames: scene.anims.generateFrameNames('atlas', {
            prefix: 'mario-atlas_',
            start: 6,
            end: 9,
        }),
        frameRate: 10,
        repeat: -1
    });
};

function increaseScore(score){
    const scoreElement = document.getElementsByClassName('score-amount')[0];
    const currentScore = Number(scoreElement.innerText);
    scoreElement.innerText = currentScore + score;
}

const options = {

    width: 640, //wymiary mapki
    height:480,

    parent:mapa, // div.id -> mapa
    backgroundColor:'#FFFFAC', //kolor tła gry, ustawiam taki, zeby bylo spójne z kafelkami, ltore maja taki sam kolor tla
    title: 'Mapka do gry Mario by Wojtek', //tytul wyswietla sie w konsoli
    pixelArt: true,//gdy false to mario rozmazany, inaczej mario jest pikseolwy czyli jest OK

    physics: {
        default: 'arcade', //domyslny silnik fizyki 
        arcade: {
            // debug: true, // sledzi kazdy obiekt, podswietla go
            gravity: { //grawitacja w gore im wieksza tym bardziej przyciaga do ziemi
                //x:1000,//gdy ustawimy x to będzie przesuwało mario
                y: 900
            }
        }
    },
    //sceny jakie sie moga pojawic(glowna,przegrana, wygrana)
    scene: [
        Game,
        GameOver,
        GameWinner
    ]
};
const game=new Phaser.Game(options);