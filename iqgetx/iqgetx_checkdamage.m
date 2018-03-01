function ok = iqgetx_checkdamage(sIqgetx)

clf;

subplot(3,1,1); hold all
title([sIqgetx.title ': Before Buffer Images'])
for i=1:length(sIqgetx.buf1imgs)
   plot(sIqgetx.buf1imgs(i).iq(:,1), sIqgetx.buf1imgs(i).iq(:,2)- ...
        sIqgetx.buf1imgs(1).iq(:,2));
end
ylabel('I(Q)')

subplot(3,1,2); hold all
title('Sample Images')
for i=1:length(sIqgetx.samimgs)
   plot(sIqgetx.samimgs(i).iq(:,1), sIqgetx.samimgs(i).iq(:,2)- ...
        sIqgetx.samimgs(1).iq(:,2));
end
ylabel('I(Q)')

subplot(3,1,3); hold all
title('After Buffer Images')
for i=1:length(sIqgetx.buf2imgs)
   plot(sIqgetx.buf2imgs(i).iq(:,1), sIqgetx.buf2imgs(i).iq(:,2)- ...
        sIqgetx.buf2imgs(1).iq(:,2));
end
ylabel('I(Q)')


