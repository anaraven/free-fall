red <- read.table("median-R.tsv", header=FALSE)
green <- read.table("median-G.tsv", header=FALSE)
blue <- read.table("median-B.tsv", header=FALSE)
grey <- (red + green + blue)/3

min_max <-range(c(red[[100]], green[[100]], blue[[100]]))
plot(red[[100]], type="l", col="red", ylim=min_max)
lines(green[[100]], type="l", col="green")
lines(blue[[100]], type="l", col="blue")

min_max <-range(c(red, green, blue))
frames <- 1:ncol(red)
library(animation)
saveGIF({
    for(i in frames) {
        plot(red[[i]],type="l",col="red", ylim=min_max)
        lines(green[[i]],type="l",col="green")
        lines(blue[[i]],type="l",col="blue")
    }
},interval=1/30, movie.name = "RGB.gif")

saveVideo({
    for(i in frames) {
        plot(red[[i]],type="l",col="red", ylim=min_max)
        lines(green[[i]],type="l",col="green")
        lines(blue[[i]],type="l",col="blue")
    }
}, interval=1/30, video.name = "RGB.mp4")


red <- red - rep(apply(red, 1, median), 700)
green <- green - rep(apply(green, 1, median), 700)
blue <- blue - rep(apply(blue, 1, median), 700)

min_max <-range(c(red[[100]],green[[100]], blue[[100]]))
plot(red[[100]],type="l",col="red", ylim=min_max)
lines(green[[100]],type="l",col="green")
lines(blue[[100]],type="l",col="blue")

min_max <-range(c(red, green, blue))
saveGIF({
    for(i in frames) {
        plot(red[[i]],type="l",col="red", ylim=min_max)
        lines(green[[i]],type="l",col="green")
        lines(blue[[i]],type="l",col="blue")
    }
}, interval=1/30, movie.name = "normalized.gif")

saveVideo({
  for(i in frames) {
    plot(red[[i]],type="l",col="red", ylim=min_max)
    lines(green[[i]],type="l",col="green")
    lines(blue[[i]],type="l",col="blue")
  }
}, interval=1/30, video.name = "normalized.mp4")

yellow <- (red+green)/2-blue
plot(yellow[[100]], type="l")

min_max <-range(yellow)
ry <- mean(min_max)
saveGIF({
  for(i in frames) {
    plot(yellow[[i]],type="l", ylim=min_max)
    my80 <- max(yellow[i])*0.8
    segments(min(which(yellow[[i]]>my80)), ry,
             max(which(yellow[[i]]>my80)), ry, col="red", lwd=5)
  }
}, interval=1/30, movie.name = "yellow.gif")

saveVideo({
    for(i in frames) {
        plot(yellow[[i]],type="l", ylim=min_max)
        my80 <- max(yellow[i])*0.8
        segments(min(which(yellow[[i]]>my80)), ry,
                max(which(yellow[[i]]>my80)), ry, col="red", lwd=5)
    }
}, interval=1/30, video.name = "yellow.mp4")

pixels <- 1:nrow(yellow)

plot(pixels, pixels, type="n", ylab="pixels", xlab="frame",
     xlim=range(frames))
for(i in frames) {
    lines(0.1*yellow[[i]]+i, rev(pixels))
}

which(yellow[100]>max(yellow[100])*0.8)
range(which(yellow[100]>max(yellow[100])*0.8))
mean(range(which(yellow[100]>max(yellow[100])*0.8)))

px <- sapply(yellow, function(x) mean(range(which(x>max(x)*0.8))))
y <- -px/80 * 0.19 
time <- frames/240
time_sq <- time*time
#etime <- (1-exp(-time*1000))

model <- lm(y ~ time + time_sq)
plot(resid(model))
summary(model)
plot(y ~ time)
lines(predict(model) ~ time, col="red", lwd=2)


r1 <- grey[21:650, 1]
r2 <-  sapply(-10:10, function(i) grey[(i+20):(i+649),136])
plot(cor(r1,r2)[1, ])

disp <- sapply(frames, function(k) {
  r2 <-  sapply(-10:10, function(i) grey[(i+20):(i+649),k])
  ans <- cor(r1,r2)[1,]
  c(max(ans), which.max(ans)-12)
})
plot(disp[2,] ~ frames)

y <- -(px-disp[2,])/80 * 0.19 
time <- frames/240
time_sq <- time*time

plot(y ~ time)
model <- lm(y ~ time + time_sq)



model_disp <- lm(disp[2,] ~ frames+ I(frames*frames)+0, weights = disp[1,])
shift <- predict(model_disp)
lines(shift,col="blue")

y <- -(px-shift)/80 * 0.19 
time <- frames/240
time_sq <- time*time

plot(y ~ time)
model <- lm(y ~ time + time_sq)
summary(model)
lines(predict(model) ~ time, col="red")


## the rest is invalid
plot(red[[136]],type="l")
plot(red[[136]]^2,type="l")
a <- which(red[[136]]^2>700)
plot(a)
hist(a, nclass=40, col="grey")
z <- tapply(a, cut(a, 9), min)
plot(diff(z))
mtr <- 1:9 * 0.19  # esto es lo que hay que cambiar
# pixel de la cámara no es pixel de la pantalla
model <- lm(mtr ~ z)
plot(resid(model))
model <- lm(mtr ~ z+I(z^2))
plot(resid(model))
summary(model)
predict(model)*100
