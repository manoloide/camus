class Enemigo extends Elemento {
  float dano = 0.1;
  void dano(Jugador j) {
    if(eliminar) return;
    if (colisiona(j) && !j.inmune && !j.invisible) {
      j.dano(dano);
    }
  }
}

class Mouse extends Enemigo {
  int frame;
  float vel, velx, vely;
  Mouse(int x, int y) {
    this.x = x; 
    this.y = y;
    w = 21;
    h = 11;
    p1 = null;
    p2 = null;
    vel = 1;
    velx = vel;
    vely = 0;
    puntos = false;
  }
  void act() {
    if (frameCount%6 == 0) frame++;
    frame %= 4;
    float antx = x; 
    float anty = y;
    x += velx;
    if (nivel.colisiona(this)) {
      velx *= -1;
      x = antx;
    }
    vely += 1;
    y += vely;
    if (nivel.colisiona(this)) {
      y = anty;
      vely = 0;
    }
  }
  void dibujar() {
    int dir = 0;
    if (velx < 0) dir = 1;
    if (dir == 0) {
      image(sprites_mouse[frame][0], x-w/2, y-h/2);
    }
    else {
      image(espejar(sprites_mouse[frame][0]), x-w/2, y-h/2);
    }
  }
  boolean colisiona(Jugador ju) {
    if (colisionRect(ju.x, ju.y, ju.w, ju.h, x, y+3, w, h-6)) {
      return true;
    }
    return false;
  }
}

class Dove extends Enemigo {
  boolean posarse;
  int frame, tposarse, alturaMax;
  float vel, velx, vely, dy;
  Dove(int x, int y, int px1, int py1, int px2, int py2) {
    this.x = x; 
    this.y = y;
    w = h = 16;
    alturaMax = tam*2;
    p1 = new Punto(px1, py1);
    p2 = new Punto(px2, py2);
    obj = new Punto(px1, py1);
    float ang = atan2(obj.y-y, obj.x-x);
    vel = 1;
    velx = cos(ang)*vel;
    vely = sin(ang)*vel;
    puntos = true;
  }
  void act() {
    if (posarse) {
      if (frameCount%6 == 0) { 
        frame++;
        frame = (frame%2)+3;
      }
      tposarse--;
      if (tposarse <= 0) posarse = false;
    }
    else {
      if (frameCount%6 == 0) frame++;
      frame %= 3;
      float ang = atan2(obj.y-y, obj.x-x);
      velx = cos(ang)*vel;
      vely = sin(ang)*vel;
      x += velx;
      y += vely;
    }
    float dis = min(dist(x, y, p1.x, p1.y), dist(x, y, p2.x, p2.y));
    if (dis < alturaMax) {
      dy = -dis*cos(map(dis, alturaMax, 0, 0, PI/2));
    }
    else {
      dy = -alturaMax;
    }
    if (dist(x, y, obj.x, obj.y) < vel) {
      posarse = true;
      tposarse = 80;
      if (dist(p1.x, p1.y, obj.x, obj.y) < vel) {
        obj.x = p2.x;
        obj.y = p2.y;
      }
      else if (dist(p2.x, p2.y, obj.x, obj.y) < vel) {
        obj.x = p1.x;
        obj.y = p1.y;
      }
    }
  }
  void dibujar() {
    int dir = 0;
    if (velx < 0) dir = 1;
    if (dir == 0) image(sprites_dove[frame][0], x-w/2, y-h/2+dy);
    else image(espejar(sprites_dove[frame][0]), x-w/2, y-h/2+dy);
    /*
    fill(255, 0, 0, 120);
     rect(x-w/2, y-h/2+dy, w, h);
     */
  }
  boolean colisiona(Jugador ju) {
    if (colisionRect(ju.x, ju.y, ju.w, ju.h, x, y+dy, w, h)) {
      return true;
    }
    return false;
  }
}

class Serpent extends Enemigo { 
  int frame;
  float vel, velx, vely;
  Serpent(int x, int y, int px1, int py1, int px2, int py2) {
    this.x = x; 
    this.y = y;
    w = 32;
    h = 8;
    p1 = new Punto(px1, py1);
    p2 = new Punto(px2, py2);
    obj = new Punto(px1, py1);
    float ang = atan2(obj.y-y, obj.x-x);
    vel = 1;
    velx = cos(ang)*vel;
    vely = sin(ang)*vel;
    puntos = true;
  }
  void act() {
    if (frameCount%6 == 0) frame++;
    frame %= 5;
    float antx = x; 
    float anty = y;
    float ang = atan2(obj.y-y, obj.x-x);
    velx = cos(ang)*vel;
    vely = sin(ang)*vel;
    x += velx;

    vely += 1;
    y += vely;
    if (nivel.colisiona(this)) {
      y = anty;
      vely = 0;
    }
    if (dist(x, y, obj.x, obj.y) < vel) {
      if (dist(p1.x, p1.y, obj.x, obj.y) < vel) {
        obj.x = p2.x;
        obj.y = p2.y;
      }
      else if (dist(p2.x, p2.y, obj.x, obj.y) < vel) {
        obj.x = p1.x;
        obj.y = p1.y;
      }
    }
  }
  void dibujar() {
    int dir = 0;
    if (velx < 0) dir = 1;
    if (dir == 0) image(sprites_serpent[frame][0], x-w/2, y-h/2);
    else image(espejar(sprites_serpent[frame][0]), x-w/2, y-h/2);
  }
}

class Rat extends Enemigo {
  boolean seguir, salto;
  int frame, dir, tiempo_reposo;
  float vel, velx, vely, max_dis;
  Rat(int x, int y) {
    this.x = x; 
    this.y = y;
    w = h = 33;
    p1 = null;
    p2 = null;
    obj = new Punto(x, y);
    float ang = atan2(obj.y-y, obj.x-x);
    vel = 1;
    velx = cos(ang)*vel;
    vely = sin(ang)*vel;
    max_dis = 250;
    seguir = false;
    puntos = false;
    tiempo_reposo = 0;
  }
  void act() {
    obj = new Punto(nivel.jugador.x, nivel.jugador.y);
    float dis = dist(obj.x, obj.y, x, y);
    if (dis < max_dis && !nivel.jugador.invisible) {
      if (!seguir && (dir == 0 && x-obj.x < 0) || (dir == 1 && x-obj.x > 0)) {
        seguir = true;
      }
    }
    else {
      seguir = false;
    }
    if (seguir) {
      float ang = atan2(obj.y-y, obj.x-x);
      if (cos(ang)*vel < 0) {
        velx = -vel;
      }
      else if (cos(ang)*vel > 0) {
        velx = vel;
      }
      else {
        velx = 0;
      }
      seguir = true;
      dir = 0;
      if (velx < 0) dir = 1;
    }
    else {
      velx = 0;
      tiempo_reposo++;
      dir = (tiempo_reposo/180)%2;
      if (seguir) { 
        tiempo_reposo = 0;
        seguir = false;
      }
    }

    float antx = x; 
    float anty = y;
    x += velx;
    if (nivel.colisiona(this)) {
      x = antx;
      if (!salto) {
        salto = true;
        vely = -16;
      }
    }

    vely += 1;
    y += vely;
    if (nivel.colisiona(this)) {
      y = anty;
      salto = false;
      if (vely > 0) {
        //cant_sal = 0;
      }
      vely = 0;
    }
    if (seguir) {
      if (frameCount%3 == 0) frame++;
      frame %= 8;
    }
    else {
      if (frameCount%8 == 0) frame++;
      frame = frame%2 + 8;
    }
  }
  void dibujar() {
    if (dir == 0) {
      image(sprites_rat[frame][0], x-w/2, y-h/2);
    }
    else {
      image(espejar(sprites_rat[frame][0]), x-w/2, y-h/2);
    }
  }
}

class Hawk extends Enemigo {
  int frame, tataque;
  float vel, velx, vely;
  String estado;
  Hawk(int x, int y, int px1, int py1, int px2, int py2) {
    this.x = x; 
    this.y = y;
    w = 60;
    h = 50;
    p1 = new Punto(px1, py1);
    p2 = new Punto(px2, py2);
    obj = new Punto(px1, py1);
    float ang = atan2(obj.y-y, obj.x-x);
    vel = 1;
    velx = cos(ang)*vel;
    vely = sin(ang)*vel;
    puntos = true;
    estado = "normal";
    tataque = int(random(300, 600));
  }
  void act() {
    if (estado.equals("normal")) {
      if (frameCount%6 == 0) frame++;
      frame %= 10;
      float ang = atan2(obj.y-y, obj.x-x);
      velx = cos(ang)*vel;
      vely = sin(ang)*vel;
      x += velx;
      y += vely;
      if (dist(x, y, obj.x, obj.y) < vel) {
        vel = 1;
        if (dist(p1.x, p1.y, obj.x, obj.y) < vel) {
          obj.x = p2.x;
          obj.y = p2.y;
        }
        else if (dist(p2.x, p2.y, obj.x, obj.y) < vel) {
          obj.x = p1.x;
          obj.y = p1.y;
        }
      }
      tataque--;
      if (tataque < 0 && dist(x, y, nivel.jugador.x, nivel.jugador.y) < 420) {
        estado = "atacar";
        obj = new Punto(nivel.jugador.x, nivel.jugador.y);
      }
    }
    else if (estado.equals("atacar")) {
      vel = 6;
      if (frameCount%3 == 0) frame++;
      frame %= 10;
      float ang = atan2(obj.y-y, obj.x-x);
      velx = cos(ang)*vel;
      vely = sin(ang)*vel;
      x += velx;
      y += vely;
      if (dist(x, y, obj.x, obj.y) < vel) {
        tataque = int(random(300, 600));
        vel = 2;
        estado = "normal";
        if (dist(p1.x, p1.y, x, y) < dist(p2.x, p2.y, x, y)) { 
          obj.x = p1.x;
          obj.y = p1.y;
        }
        else {
          obj.x = p2.x;
          obj.y = p2.y;
        }
      }
    }
  }
  void dibujar() {
    int dir = 0;
    if (velx < 0) dir = 1;
    if (dir == 0) image(sprites_hawk[frame%2][frame/2], x-w/2, y-h/2);
    else image(espejar(sprites_hawk[frame%2][frame/2]), x-w/2, y-h/2);
  }
}

class Viper extends Enemigo {
  int dir, frame;
  float vel, velx, vely, max_dis;
  String estado;
  Viper(int x, int y, int px1, int py1, int px2, int py2) {
    this.x = x; 
    this.y = y;
    w = 101;
    h = 18;
    p1 = new Punto(px1, py1);
    p2 = new Punto(px2, py2);
    obj = new Punto(px1, py1);
    float ang = atan2(obj.y-y, obj.x-x);
    vel = 1;
    velx = cos(ang)*vel;
    vely = sin(ang)*vel;
    max_dis = 200;
    puntos = false;
    estado = "normal";
  }
  void act() {
    if (estado.equals("normal")) {
      if (frameCount%6 == 0) frame+=3;
      frame %= 15;
    }
    else if (estado.equals("atacar")) {
      if (frameCount%6 == 0) frame++;
      frame %= 5;
    }
    float antx = x; 
    float anty = y;
    float ang = atan2(obj.y-y, obj.x-x);
    if (estado.equals("normal")) {
      velx = cos(ang)*vel;
      x += velx;
      dir = 0;
      if (velx < 0) dir = 1;
      vely += 1;
      y += vely;
      if (nivel.colisiona(this)) {
        y = anty;
        vely = 0;
      }
      else {
        p1.y += vely;
        p2.y += vely;
      }

      if (dist(x, y, obj.x, obj.y) < vel) {
        if (dist(p1.x, p1.y, obj.x, obj.y) < vel) {
          obj.x = p2.x;
          obj.y = p2.y;
        }
        else if (dist(p2.x, p2.y, obj.x, obj.y) < vel) {
          obj.x = p1.x;
          obj.y = p1.y;
        }
      }
    }
  }
  void dibujar() {
    if (estado.equals("normal")) {
      if (dir == 0) image(sprites_viper[frame%3][frame/3], x-w/2, y-h/2);
      else image(espejar(sprites_viper[frame%3][frame/3]), x-w/2, y-h/2);
    }
    else if (estado.equals("atacar")) {
      if (dir == 0 || true) {
        image(sprites_viper[frame%3][frame/6+5], x-w/2, y-h);
        image(sprites_viper[frame%3][frame/6+6], x-w/2, y);
      }
      else {
        image(espejar(sprites_viper[frame%3][frame/3]), x-w/2, y-h/2);
      }
    }
  }
}

class Wolf extends Enemigo {
  boolean seguir, salto;
  int frame, dir, tiempo_reposo;
  float vel, velx, vely, max_dis;
  Wolf(float x, float y) {
    this.x = x; 
    this.y = y;
    w = 114;
    h = 57;
    obj = new Punto(x, y);
    float ang = atan2(obj.y-y, obj.x-x);
    vel = 1;
    velx = cos(ang)*vel;
    vely = sin(ang)*vel;
    max_dis = 250;
    seguir = false;
    puntos = false;
    tiempo_reposo = 0;
  }
  void act() {
    if (frameCount%6 == 0) frame++;
    frame %= 9;
    obj = new Punto(nivel.jugador.x, nivel.jugador.y);
    float dis = dist(obj.x, obj.y, x, y);
    if (dis < max_dis && !nivel.jugador.invisible) {
      if (!seguir && (dir == 0 && x-obj.x < 0) || (dir == 1 && x-obj.x > 0)) {
        seguir = true;
      }
    }
    else {
      seguir = false;
    }
    if (seguir) {
      float ang = atan2(obj.y-y, obj.x-x);
      if (cos(ang)*vel < 0) {
        velx = -vel;
      }
      else if (cos(ang)*vel > 0) {
        velx = vel;
      }
      else {
        velx = 0;
      }
      seguir = true;
      dir = 0;
      if (velx < 0) dir = 1;
    }
    else {
      velx = 0;
      tiempo_reposo++;
      dir = (tiempo_reposo/180)%2;
      if (seguir) { 
        tiempo_reposo = 0;
        seguir = false;
      }
    }

    float antx = x; 
    float anty = y;
    x += velx;
    if (nivel.colisiona(this)) {
      x = antx;
      if (!salto) {
        salto = true;
        vely = -16;
      }
    }

    vely += 1;
    y += vely;
    if (nivel.colisiona(this)) {
      y = anty;
      salto = false;
      if (vely > 0) {
        //cant_sal = 0;
      }
      vely = 0;
    }
  }
  void dibujar() {
    if (dir == 0)
      image(sprites_wolf[frame%2][frame/2], x-w/2, y-h/2);
    else
      image(espejar(sprites_wolf[frame%2][frame/2]), x-w/2, y-h/2);
  }
}

class Vulture extends Enemigo {
  int frame;
  float vel, velx, vely;
  Vulture(int x, int y, int px1, int py1, int px2, int py2) {
    this.x = x; 
    this.y = y;
    w = 93;
    h = 70;
    p1 = new Punto(px1, py1);
    p2 = new Punto(px2, py2);
    obj = new Punto(px1, py1);
    float ang = atan2(obj.y-y, obj.x-x);
    vel = 1;
    velx = cos(ang)*vel;
    vely = sin(ang)*vel;
    puntos = false;
  }
  void act() {
    if (frameCount%6 == 0) frame++;
    frame %= 3;
    float ang = atan2(obj.y-y, obj.x-x);
    velx = cos(ang)*vel;
    vely = sin(ang)*vel;
    x += velx;
    y += vely;
    if (abs(nivel.jugador.x-x) < w/2 && frameCount%80 == 0) {
      Huevo h = new Huevo(x, y);
      nivel.elementos.add(h); 
      nivel.enemigos.add(h);
    }
    if (dist(x, y, obj.x, obj.y) < vel) {
      if (dist(p1.x, p1.y, obj.x, obj.y) < vel) {
        obj.x = p2.x;
        obj.y = p2.y;
      }
      else if (dist(p2.x, p2.y, obj.x, obj.y) < vel) {
        obj.x = p1.x;
        obj.y = p1.y;
      }
    }
  }
  void dibujar() {
    int dir = 0;
    if (velx < 0) dir = 1;
    if (dir == 0) image(sprites_vulture[frame][0], x-w/2, y-h/2);
    else image(espejar(sprites_vulture[frame][0]), x-w/2, y-h/2);
  }
}

class Cobra extends Enemigo {
  boolean seguir, salto;
  int frame, dir, tiempo_reposo;
  float vel, velx, vely, max_dis;
  Cobra(float x, float y) {
    this.x = x; 
    this.y = y;
    w = 100;
    h = 50;
    obj = new Punto(x, y);
    float ang = atan2(obj.y-y, obj.x-x);
    vel = 1;
    velx = cos(ang)*vel;
    vely = sin(ang)*vel;
    max_dis = 250;
    seguir = false;
    puntos = false;
    tiempo_reposo = 0;
  }
  void act() {
    if (frameCount%6 == 0) frame++;
    frame %= 9;
    obj = new Punto(nivel.jugador.x, nivel.jugador.y);
    float dis = dist(obj.x, obj.y, x, y);
    if (dis < max_dis && !nivel.jugador.invisible) {
      if (!seguir && (dir == 0 && x-obj.x < 0) || (dir == 1 && x-obj.x > 0)) {
        seguir = true;
      }
    }
    else {
      seguir = false;
    }
    if (seguir) {
      float ang = atan2(obj.y-y, obj.x-x);
      if (cos(ang)*vel < 0) {
        velx = -vel;
      }
      else if (cos(ang)*vel > 0) {
        velx = vel;
      }
      else {
        velx = 0;
      }
      seguir = true;
      dir = 0;
      if (velx < 0) dir = 1;
    }
    else {
      velx = 0;
      tiempo_reposo++;
      dir = (tiempo_reposo/180)%2;
      if (seguir) { 
        tiempo_reposo = 0;
        seguir = false;
      }
    }

    float antx = x; 
    float anty = y;
    x += velx;
    if (nivel.colisiona(this)) {
      x = antx;
      if (!salto) {
        salto = true;
        vely = -16;
      }
    }

    vely += 1;
    y += vely;
    if (nivel.colisiona(this)) {
      y = anty;
      salto = false;
      if (vely > 0) {
        //cant_sal = 0;
      }
      vely = 0;
    }
  }
  void dibujar() {
    if (dir == 0)
      image(sprites_cobra[frame%2][frame/2], x-w/2, y-h/2);
    else
      image(espejar(sprites_cobra[frame%2][frame/2]), x-w/2, y-h/2);
  }
}

class Huevo extends Enemigo {
  float vely;
  Huevo(float x, float y) {
    this.x = x;
    this.y = y;
    w = 18;
    h = 24;
    vely = 0;
  }
  void act() {
    vely += 0.5;
    y += vely;
    if (nivel.colisiona(this)) eliminar = true;
  }
  void dibujar() {
    noStroke();
    fill(230);
    ellipse(x, y, w, h);
  }
}