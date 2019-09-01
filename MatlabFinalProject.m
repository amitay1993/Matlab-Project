            %%Main Function
            %function gets the start date,end date and name of the file as
            %input from Gui
            %function returns play_gui to indicate if stampling found or
            %not
        
           function [play_gui,buy_gui,buy_value]=MatlabFinalProject(Start_Date,End_Date,Data_Name)
            %reads data from file as a table
            tbl=readtable(Data_Name);
            %Delete what's befor start datepla
            tbl(tbl.Date<=datetime(Start_Date,'InputFormat','dd/MM/yyyy'),:)=[];
             %Delete what's after end date
            tbl(tbl.Date>=datetime(End_Date,'InputFormat','dd/MM/yyyy'),:)=[]; 
            %convert to timetable for the candle function
            tbl=table2timetable(tbl);
            Date=tbl.Date;
            Date=datetime(Date,'InputFormat','dd/MM/yyyy');
            %assigning variables for eatch colume of table
            Low_Gate=tbl.low;
            High_Gate=tbl.high;
            Open_Gate=tbl.open;
            Last_Gate=tbl.close;
            Low_Gate_new=tbl.low;
            High_Gate_new=tbl.high;
            %creating empty vectors for min and max points
            maxLoc=[];
            minLoc=[];
            min_new=[];
            max_new_price=[]; 
            len_High=length(High_Gate);
            len_Low=length(Low_Gate);
            %variables for long buy 
            check_diff=[];
            sum=0; 
            buy_gui=0;
            d=len_High-90; 
            %creating simple moving average for aligator
            meridian_price=(Low_Gate+High_Gate)/2;
            ma_medianPrice13 = SMA(meridian_price,13,8);
            ma_medianPrice8 = SMA(meridian_price,8,5);
            ma_medianPrice5 = SMA(meridian_price,5,3);
            len_ma13=length(ma_medianPrice13);
            len_ma8=length(ma_medianPrice8);
            len_ma5=length(ma_medianPrice5);
            iter=min(len_ma13);(len_ma8);(len_ma5);
            a13=ma_medianPrice13;
            b8=ma_medianPrice8;
            c5=ma_medianPrice5; 
            %Stampling algorithm explained at the begining of the word file
            Xfirst=[];
                Yfirst=[];
                Xlast=[];
                Ylast=[];
                Xlast_final=[];
                temp=[];
                play=false;
                play_gui=0;
          
          j=1;
          %the loop starts to check the values along the length of the
          %vector
          while j<(iter-1)
             counter=1;
             boom=true;
             diff13=((a13(j))-a13(j+1))./(a13(j+1));
             diff8=((b8(j))-b8(j+1))./(b8(j+1));
             diff5=(c5(j)-c5(j+1))./(c5(j+1));
             
             up_down_ab=(a13(j)-b8(j))./(b8(j));
             up_down_ac=(a13(j)-c5(j))./(c5(j));
             %checking if the values differ more then 
             %0.0065 from each other
             index13=abs(diff13)<0.0065;
             index8=abs(diff8)<0.0065;
             index5=abs(diff5)<0.0065; 
             
             index13_8=abs(up_down_ab)<0.0065;
             index13_5=abs(up_down_ac)<0.0065;             
                  %if all false,stampling didnt start-continue       
                  if(index13==false||index8==false||index5==false||index13_5==false||index13_8==false)                    
                      j=j+1;
                      continue;
                  %if a begining of stampling found,save the first day it started    
                  else
                   
                Yfirst=a13(j);
                Xfirst=datetime(Date(j));  
                  end
    
                  %counting stampling days
                    for i=j+1:iter-1
                        boom=false;
                    counter=counter+1;                                   
                     j=i;
                     diff13=((a13(j))-a13(j+1))./(a13(j+1));
                     diff8=((b8(j))-b8(j+1))./(b8(j+1));
                     diff5=(c5(j)-c5(j+1))./(c5(j+1));
                    
                     
                     up_down_ab=(a13(j)-b8(j))./(b8(j));
                     up_down_ac=(a13(j)-c5(j))./(c5(j));
                    
                      index13_5=abs(up_down_ac)<0.0065;
                      index13_8=abs(up_down_ab)<0.0065;
                      index13=abs(diff13)<0.0065;
                      index8=abs(diff8)<0.0065;
                      index5=abs(diff5)<0.0065; 
                     %checking if stampling is found.if it is
                     %found,checking if it lasted at least 14
                     %days(counter>14)
                     if(index13==false||index8==false||index5==false||index13_5==false||index13_8==false)
                         boom=false;                         
                         if (counter>14)
                             boom=true;                            
                         else
                             break;
                         end
                     end 
              %If stampling is found,plot yellow boxes and sound the finding cue     
              if(boom==true)
                  figure(1)
                   play=true;
                   play_gui=1;
                   Ylast=[Yfirst,a13(j-1)];                   
                   Xlast=[Xfirst,Date(j-1)];
                   temp=Xlast;
                   Xlast_final=[Xlast,temp];
                   temp1=Ylast;
                   Ylast_final=[Ylast,temp1];
                   hold on                   
                   fill(Xlast_final([1,2,2,1]),Ylast([1,1,2,2]),'yellow')
                   
                  
              else
                  continue;
              end              
               j=j+1;
               break;
                    end
          end
                                    
            

          %%finding min points of low gate and max points of high gate 
          %the script takes the index+2 and checks between them if the middle(index+1)has the highest value
          %and the inserts it to the empty vector(maxLoc)
          for i=1:len_High-2
            if High_Gate(i)<High_Gate(i+1)&&High_Gate(i+1)>High_Gate(i+2)
            maxLoc=[maxLoc,i+1];
            High_Gate_new(i+1)=High_Gate_new(i+1);%vector for diamonds higher by 5% on graph
            end
          end
           %the script takes the index+2 and checks between them if the middle(index+1)has the lowest value
           %and the inserts it to the empty vector(minLoc)
            for i=1:len_Low-2 
            if Low_Gate(i)>Low_Gate(i+1)&&Low_Gate(i+1)<Low_Gate(i+2)
            minLoc=[minLoc,i+1];
            Low_Gate_new(i+1)=Low_Gate_new(i+1);%vector for diamonds lower by 5% on graph
            end
            end
            
            %%Long Invest advice
            %calculates the diffrence between a a day and the following
            %day.
            if(len_High>90)
                
             for i=len_High:-1:d               
                     check_diff=[check_diff,High_Gate(i)-High_Gate(i-1)];
             end
            
               
                %sum of all the the values between the days.
                %if the value is positive we are going up. from the given
                %day.
                %if the value is negative we are going down through those
                %90 days. 
                for k=1:89
                    sum=sum+check_diff(k);
                end
         
            %calculates the local max of the High Gate.    
            for i=1:len_High-2              
            if High_Gate(i)<High_Gate(i+1)&&High_Gate(i+1)>High_Gate(i+2)
                 maxLoc=[maxLoc,i+1];
            end
           end
                 
            %the index of the last max in the maxlock vector.      
            index_buy=maxLoc(end);
            %the value of the last max in maxlock vector
            buy_stop=High_Gate(index_buy);
            buy_value=num2str(buy_stop);
            if(i>=90)
                %checking rasing precentege of graph.If below 15%,it will not count as a raise 
                buy=(sum/High_Gate(i-90));
                if(buy>=0.15)
                
                buy_gui=1;
                end
            end
            else
                buy_value=0;
            end
            
            
            %%plotting graphs
            figure(1) 
            grid on   
            hold on
            candle(tbl)
            plot(Date(1:length(ma_medianPrice13)),ma_medianPrice13,'blue','linewidth',1.75)
            plot(Date(1:length(ma_medianPrice8)),ma_medianPrice8,'red','linewidth',1.75)
            plot(Date(1:length(ma_medianPrice5)),ma_medianPrice5,'green','linewidth',1.75)
            plot(Date,High_Gate,'cyan')
            plot(Date,Low_Gate,'black')
            plot(Date(minLoc),Low_Gate(minLoc)*0.995,'r*')
            plot(Date(maxLoc),High_Gate(maxLoc),'g*')
            plot(Date(maxLoc),High_Gate_new(maxLoc)*1.005,'gd')
            plot(Date(minLoc),Low_Gate_new(minLoc),'rd')
            if(play==true)
            [y,Fs] = audioread('dishdosh.wav');
            sound(y,Fs);
            
            end
            end
            
            
            
            %%Simple Moving Average
            %function gets median price,time period of sma and a shift to
            %future as inputs
            function [res] = SMA(data, period, shift)

             startindex = 1;
             p = 0;
            %creating the solution vector with Nans so that the graph will
            %start from the index+time shift
            res = NaN(length(data) - period + 1, 1);
            %calculating the sum for the movenig average
             while startindex <= (length(data) - period + 1)
                for i = startindex:1:(startindex+period-1)
                    p = p + data(i);    
                end
                %filling the solution vector from the current index plus
                %time shift creating a shift to future and calculting the
                %moving average(p / period)
                res(startindex + shift) = p / period;
                %advancing startindex
                startindex = startindex + 1;

                p = 0;
             end
            end
            %-------------------------------------------
            
            
           



