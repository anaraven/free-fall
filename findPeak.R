signal <- read.delim("median.tsv", header=FALSE)

frames <- 1:ncol(signal)
pixels <- 1:nrow(signal)

plot(pixels, pixels, type="n", ylab="pixels", xlab="frame",
     xlim=range(frames))
for(i in frames) {
  lines(0.1*signal[[i]]+i,rev(pixels))
}

signal1 <- sapply(frames, function(i) runmed(signal[[i]], k=11))
image(x=frames, y=pixels, z=t(signal1)[,rev(pixels)],
      useRaster = TRUE, col = terrain.colors(200))
#d2 <- sapply(1:ncol(signal1), function(i) {
#  convolve(signal1[,i], c(1,4,6,4,1)/16, type = "o")})
#image(x=frames, y=pixels, z=t(d2)[,rev(pixels)],
#      useRaster = TRUE, col = terrain.colors(200))

fall <- data.frame(frames, y = -apply(signal[30:700,],2,which.max))
plot(y ~ frames, fall)
fall$px <- -apply(signal1[30:700,], 2, which.max)
plot(px ~ frames, fall)
model_y <- lm(px ~ frames + I(frames^2), subset=frames<128, data=fall)
fall$y_med <- runmed(fall$px, k=3)
plot(y_med ~ frames, fall)

fall$z <- cumsum(runmed(fall$px, k=3))
plot(z ~ frames,  data=fall)
model_z <-lm(z~frames+ I(frames^3)+0, data=fall)
lines(predict(model_z) ~ frames, data=fall)

#y <- -apply(signal[30:700,1:120], 2, function(i) {
#  mean(which(signal1[,i]/max(signal1[,i])>0.95))})
#plot(y)
#plot(runmed(y,k=11))

f <- read.delim("read-20181208T0857.txt", stringsAsFactors=FALSE)
f <- subset(f, !is.na(millisec))
#duplicated(f$millisec)
#subset(f, !duplicated(millisec))
plot(millisec~frame, f)

plot(diff(f$millisec)/diff(f$frame))
abline(h=10)
thr = min(f$frame[(diff(f$millisec)/diff(f$frame)) <10])
plot(diff(f$millisec)/diff(f$frame), type="n")
text(diff(f$millisec)/diff(f$frame), labels=f$frame, cex=0.5)
abline(v=which(f$frame==thr))

plot(millisec~frame, f, subset=frame>=thr)
plot(millisec~frame, f, subset=frame<thr)
model_time <- lm(millisec~frame, f, subset=frame>=thr)
coef(model_time)
confint(model_time)
fall$time <- (fall$frames-1)*coef(model_time)["frame"]

plot(signal[,ncol(signal)], type="l")
abline(h=12)
px <- which(signal[,ncol(signal)]>12)
hist(px, nclass=10,col="grey")
bar <- cut(px, 5)
cm <- as.numeric(bar)*18*2
plot(cm~px)
model_dist <- lm(cm ~ px)
abline(model_dist)
fall$y_m <- predict(model_dist, newdata=data.frame(px=fall$px))/100
fall$t_sec <- fall$time/1000
fall$t_sec2 <- fall$t_sec^2

plot(y_m ~ t_sec, data=fall)
model_end <- lm(y_m ~ t_sec + t_sec2, data=fall, subset=frames<138)
lines(predict(model_end,newdata=fall)~ t_sec, data=fall)
summary(model_end)
